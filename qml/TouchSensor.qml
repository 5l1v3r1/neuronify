import QtQuick 2.0
import "paths"
import "hud"

Entity {
    id: sensorRoot
    objectName: "touchSensor"
    fileName: "TouchSensor.qml"

    property int cells: 5
    property var dropFunction

    width: cells * 100
    height: 100

    controls: Component {
        SensorControls {
            id: sensorControls
            sensor: sensorRoot
            onDeleteClicked: {
                simulatorRoot.deleteSensor(sensor)
            }
        }
    }

    Component.onCompleted: {
        dropFunction = simulator.createConnectionToPoint
        resetCells()
    }

    function resetCells() {
        for(var i = 0; i < repeater.count; i++) {
            var cell = repeater.itemAt(i)
            for(var j in cell.connections) {
                var connection = cell.connections[j]
                deleteConnection(connection)
            }
        }
        repeater.model = cells
    }

    onStep: {
        for(var i = 0; i < repeater.count; i++) {
            var cell = repeater.itemAt(i)
            cell.step(dt)
        }
    }

    function dump(index, entities) {
        var outputString = ""
        outputString += _basicSelfDump(index)
        for(var j = 0; j < repeater.count; j++) {
            var cell = repeater.itemAt(j)

            for(var k in cell.connections){
                var toNeuron = cell.connections[k].itemB
                var indexOfToNeuron = entities.indexOf(toNeuron)
                outputString += "connectEntities(" + sensorName + ".cellAt(" + j + "), entity" + indexOfToNeuron + ")\n"
            }
        }
        return outputString
    }

    function cellAt(index) {
        var cell = repeater.itemAt(index)
        if(!cell) {
            console.warn("WARNING: No cell at index " + index)
        }
        return cell
    }

    onCellsChanged: {
        resetCells()
    }

    MouseArea {
        anchors.fill: cellRow

        function desenseAll() {
            for(var i = 0; i < repeater.count; i++) {
                var item = repeater.itemAt(i)
                item.sensing = false
            }
        }

        function senseObject(mouse) {
            desenseAll()
            var index = mouse.x / 100
            var item = repeater.itemAt(index)
            if(item) {
                item.sensing = true
            }
        }

        onPressed: {
            senseObject(mouse)
        }

        onPositionChanged: {
            senseObject(mouse)
        }

        onReleased: {
            desenseAll()
        }

        onExited: {
            desenseAll()
        }
    }

    Row {
        id: cellRow
        Repeater {
            id: repeater
            model: 0

            Entity {
                id: cell
                property string objectName: "touchSensorCell"
                signal droppedConnector(var neuron, var connector)
                property bool sensing: false
                property real voltage: 0.0
                property real timeSinceFire: 0.0
                property bool firedLastTime: false
                property real gs: 0.0
                property real dt: 0

                useDefaultMouseHandling: false

                color: cell.sensing ? "#9ecae1" : "#4292c6"
                connectionPoint: Qt.point(sensorRoot.x + cell.x + cell.width / 2,
                                          sensorRoot.y + cell.y + cell.height)

                onStep: {
                    cell.dt = dt
                }

                onOutputConnectionStep: {
                    var neuron = target
                    timeSinceFire += dt
                    var V = voltage
                    var Is = 0
                    if(sensing) {
                        gs += 20.0 * dt
                    }
                    Is = gs * (V - 60)
                    var voltageChange = - (V + 50) - Is
                    var dV = voltageChange * dt
                    voltage += dV;
                    if(firedLastTime) {
                        voltage = -100
                        gs = 0
                        firedLastTime = false
                        return
                    }

                    var shouldFire = false
                    if(voltage > 0.0) {
                        shouldFire = true
                    }
                    if(shouldFire) {
                        voltage += 100.0
                        timeSinceFire = 0.0
                        firedLastTime = true
                        neuron.stimulate(3.0)
                    }
                }

                width: 100
                height: 100

                Rectangle {
                    anchors.fill: parent
                    color: parent.color
                    border.width: cell.sensing ? width * 0.03 : width * 0.02
                    border.color: "#f7fbff"
                }

                Component.onCompleted: {
                    droppedConnector.connect(sensorRoot.dropFunction)
                }

                SCurve {
                    id: connectorCurve
                    visible: sensorRoot.selected
                    z: -1
                    color: "#4292c6"
                    startPoint: Qt.point(parent.width / 2, parent.height / 2)
                    endPoint: Qt.point(connector.x + connector.width / 2, connector.y + connector.width / 2)
                }

                Item {
                    id: connector

                    visible: sensorRoot.selected

                    Component.onCompleted: {
                        resetPosition()
                    }

                    function resetPosition() {
                        connector.x = parent.width / 2 - width / 2
                        connector.y = parent.height - height / 2
                    }

                    width: parent.width * 0.3
                    height: width

                    Rectangle {
                        id: connectorCircle
                        anchors.centerIn: parent
                        width: parent.width / 2.0
                        height: width
                        color: "#4292c6"
                        border.color: "#f7fbff"
                        border.width: 1.0
                        radius: width
                    }

                    MouseArea {
                        id: connectorMouseArea
                        anchors.fill: parent
                        drag.target: parent
                        onReleased: {
                            cell.droppedConnector(cell, connector)
                            connector.resetPosition()
                        }
                    }
                }
            }
        }
    }


    Rectangle {
        anchors {
            horizontalCenter: parent.left
            verticalCenter: parent.top
        }
        width: parent.height / 3
        height: width
        radius: width / 2
        color: "#c6dbef"
        border.width: width * 0.1
        border.color: "#f7fbff"

        Image {
            anchors.fill: parent
            anchors.margins: parent.width * 0.1
            source: "images/transform-move.png"
            smooth: true
            antialiasing: true
        }

        MouseArea {
            anchors.fill: parent
            drag.target: sensorRoot
            onPressed: {
                sensorRoot.dragging = true
                dragStarted()
            }

            onClicked: {
                sensorRoot.clicked(sensorRoot, mouse)
            }

            onReleased: {
                sensorRoot.dragging = false
            }
        }
    }
}

