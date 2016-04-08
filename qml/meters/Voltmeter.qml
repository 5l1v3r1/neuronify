import QtQuick 2.0

import QtQuick.Layouts 1.1
import QtCharts 2.1

import Neuronify 1.0

import ".."
import "../edges"
import "../hud"
import "../paths"
import "../tools"
import "../style"

/*!
\qmltype Voltmeter
\inqmlmodule Neuronify
\ingroup neuronify-meters
\brief Reads the voltage of the neurons and shows a trace plot

Neurons can connect to the voltmeter. When they do, the voltmeter shows their voltage trace
as a function of time. Each neuron gets spesific color in the voltmeter plot. To each voltmeter
there is an associated \l{VoltmeterControls} item.
*/

Node {
    id: voltmeterRoot
    objectName: "voltmeter"
    fileName: "meters/Voltmeter.qml"
    square: true
    property var connectionPlots: []
    property var colors: ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3",
        "#ff7f00", "#a65628", "#f781bf", "#999999"]

    property int currentSeries: 0

    property real timeFactor: 1000
    property real voltageFactor: 1000

    property real timeRange: 100.0e-3

    property real timeSinceLastUpdate: 0
    property real lastUpdateTime: 0

    property alias minimumValue:  dummyAxisY.min
    property alias maximumValue:  dummyAxisY.max

    property real minimumTime: (time - timeRange) * timeFactor
    property real maximumTime: time * timeFactor

    property double fontSize : 14

    property real maximumPointCount: {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios") {
            return 120.0
        } else {
            return 240.0
        }
    }

    property real time: 0.0
    property real realTime: 0.0

    controls: Component {
        MeterControls {
            meter: voltmeterRoot
            sliderMinimum: -250
            sliderMaximum: 250
            unit: "mV"
            meterType: "Voltmeter"

        }
    }
    width: 320
    height: 240
    color: Style.color.foreground

    preferredEdge: MeterEdge {}

    canReceiveConnections: false

    engine: NodeEngine {
        onStepped: {
            if((realTime - lastUpdateTime) > timeRange / maximumPointCount) {
                time = realTime
                lastUpdateTime = realTime
                for(var i in voltmeterRoot.connectionPlots) {
                    var connectionPlot = voltmeterRoot.connectionPlots[i]
                    var plot = connectionPlot.plot
                    var neuron = connectionPlot.connection.itemB
                    if(neuron) {
                        if(neuron.voltage) {
                            plot.addPoint(time * timeFactor, neuron.voltage * voltageFactor)
                        }
                    }
                }
            }
            realTime += dt
        }
    }

    savedProperties: PropertyGroup {
        property alias width: voltmeterRoot.width
        property alias height: voltmeterRoot.height
        property alias maximumValue: voltmeterRoot.maximumValue
        property alias minimumValue: voltmeterRoot.minimumValue
    }


    onEdgeAdded: {
        var item = chartViewComponent.createObject(chartContainer);
        var plot = item.plot;
        var firePlot = item.firePlot;

        var neuron = edge.itemB;
        neuron.fired.connect(function() {
            for(var i in voltmeterRoot.connectionPlots) {
                var connectionPlot = voltmeterRoot.connectionPlots[i]
                var firePlot = connectionPlot.firePlot
                var neuron2 = connectionPlot.connection.itemB
                if(neuron2 === neuron) {
                    firePlot.addPoint(time * timeFactor - 1e-1, 1000e-3 * voltageFactor)
                    firePlot.addPoint(time * timeFactor, neuron2.voltage * voltageFactor)
                    firePlot.addPoint(time * timeFactor + 1e-1, 1000e-3 * voltageFactor)
                }
            }
        });
        console.log("item: " + item)
        item.label = Qt.binding(function(){
            console.log("neuron:" + neuron);
            return neuron.label;
        });
        item.lineColor = Qt.binding(function(){
            return neuron.color;
        });
        item.showAxis = true
        item.showAxisLabel = true

        for(var i in connectionPlots) { // loop over all old plots
            var connectionPlot = connectionPlots[i]
            connectionPlot.item.showAxis = false
            connectionPlot.item.showAxisLabel = false
        }

        var newList = connectionPlots
        newList.push({item: item, connection: edge, plot: plot, firePlot: firePlot})
        connectionPlots = newList

    }

    onEdgeRemoved: {
        for(var i in connectionPlots) {
            var connectionPlot = connectionPlots[i]
            var connectionOther = connectionPlot.connection
            if(connectionOther === edge) {
                connectionPlot.item.destroy()
                connectionPlots.splice(i, 1)
                break
            }
        }
        currentSeries -= 1
        if(connectionPlots.length > 0){
            connectionPlots[connectionPlots.length -1 ].item.showAxis = true
            connectionPlots[connectionPlots.length -1 ].item.showAxisLabel = true
        }
    }


    Rectangle {
        anchors.fill: parent
        color: parent.color
        border.color: Style.border.color
        border.width: Style.border.width
        smooth: true
        antialiasing: true
    }


    ValueAxis {
        id: dummyAxisY
        min: -100.0e-3 * voltageFactor
        max: 50.0e-3 * voltageFactor
        gridVisible: false
        labelsVisible: false
        lineVisible: false
        tickCount: 2
    }

    ColumnLayout{
        id: chartContainer
        anchors.fill: parent

    }

    Component{
        id: chartViewComponent

        Item{
            id: chartItem
            property Plot plot: series
            property Plot firePlot: fireSeries
            property string label: ""
            property bool showAxis: false
            property bool showAxisLabel: false
            property color lineColor: "red"

            Layout.fillWidth: true
            Layout.fillHeight: true
            width: 1
            height: 1

            // Axis label V and t
            Text{
                id: ylabel
                anchors{
                    verticalCenter: chartView.verticalCenter
                    left: chartView.left
                    leftMargin: 20
                }
                rotation: 270
                text: "V [mV]"
                visible: chartItem.showAxisLabel && (vMin.y - vMax.y - vMax.height) > width ? true : false
                font.pixelSize: voltmeterRoot.fontSize
            }

            Text{
                id: xlabel
                anchors{
                    horizontalCenter: chartView.horizontalCenter
                    bottom: chartView.bottom
                    bottomMargin: 10
                }

                text: chartItem.showAxisLabel ? "t [ms]" : ""
                font.pixelSize: voltmeterRoot.fontSize
            }

            //Time axis min/max:
            Text{
                id: tMin
                anchors{
                    verticalCenter: xlabel.verticalCenter
                    left: vMin.right
                }

                text: voltmeterRoot.minimumTime.toFixed(0)
                font.pixelSize: voltmeterRoot.fontSize
                visible: showAxis
            }
            Text{
                id: tMax
                anchors{
                    verticalCenter: xlabel.verticalCenter
                    right: chartView.right
                    rightMargin: 20
                }

                text: voltmeterRoot.maximumTime.toFixed(0)
                font.pixelSize: voltmeterRoot.fontSize
                visible: showAxis
            }

            //Voltage axis min/max:
            Text{
                id: vMin
                anchors{
                    right: ylabel.right
                    bottom: tMin.top
                }

                text: voltmeterRoot.minimumValue.toFixed(0)
                font.pixelSize: voltmeterRoot.fontSize
                visible: showAxis
            }
            Text{
                id: vMax
                anchors{
                    right: ylabel.right
                    top: chartView.top
                    topMargin: 13
                }

                text: voltmeterRoot.maximumValue.toFixed(0)
                font.pixelSize: voltmeterRoot.fontSize
                visible:showAxis
            }

            Text{
                id: titleText
                anchors{
                    top: chartView.top
                    topMargin: 2
                    horizontalCenter: chartView.horizontalCenter

                }

                text: label
                font.pixelSize: voltmeterRoot.fontSize

            }

            ChartView {
                id: chartView
                anchors.fill: parent
                legend.visible: false
                antialiasing: true
                backgroundColor: "transparent"
                enabled: false // disables mouse input
                margins.top: 0
                margins.bottom: 0
                margins.left: 10
                margins.right: 0

                Plot {
                    id: series
                    axisX: axisX
                    axisY: axisY
                    timeRange: voltmeterRoot.timeRange * timeFactor
                    color: chartItem.lineColor

                }

                Plot {
                    id: fireSeries
                    axisX: axisX
                    axisY: axisY
                    timeRange: series.timeRange
                    color: chartItem.lineColor

                }

                ValueAxis {
                    id: axisX
                    min: voltmeterRoot.minimumTime
                    max: voltmeterRoot.maximumTime
                    tickCount: 2 // IMPORTANT: Needs to be low because something gets recalculated everytime min/max changes and tickCount depends on this
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: showAxis
                }

                ValueAxis {
                    id: axisY
                    min: voltmeterRoot.minimumValue
                    max: voltmeterRoot.maximumValue
                    tickCount: 2
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: showAxis
                }
            }
        }
    }

    ResizeRectangle {}

    Connector {}
}
