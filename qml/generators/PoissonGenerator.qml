import QtQuick 2.0
import QtQuick.Controls 1.0

import Neuronify 1.0

import "../paths"
import "../hud"
import "../controls"
import ".."

/*!
    \qmltype PoissonGenerator
    \inqmlmodule Neuronify
    \ingroup neuronify-generators
    \brief An spike generator which can suply input spikes to neurons.

    The Poisson generator can be connected to neurons, and will then suply the neurons with spikes
    generated from a poisson process.
    The generator has a control panel where you can adjust the firing rate and stimulation output, as
    well as whether or not the generated spikes are inhibitory or excitatory.
*/

Node {
    id: root

    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    readonly property bool inhibitory: root.engine.fireOutput < 0.0
    property url imageSource: "qrc:/images/generators/poisson_generator_excitatory.png"
    property url inhibitoryImageSource: "qrc:/images/generators/poisson_generator_inhibitory.png"

    property alias fireOutput: engine.fireOutput
    property alias rate: engine.rate

    savedProperties: PropertyGroup {
        property alias engine: engine
    }

    objectName: "poissonGenerator"
    fileName: "generators/PoissonGenerator.qml"

    width: 62
    height: 62
    color: inhibitory ? "#e41a1c" : "#6baed6"
    canReceiveConnections: false

    engine: NodeEngine {
        id: engine
        property real rate: 0.5e3
        fireOutput: 100.0e-6

        savedProperties: PropertyGroup {
            property alias fireOutput: engine.fireOutput
            property alias rate: engine.rate
        }

        onStepped: {
            var shouldFire = (Math.random() < rate*dt)
            if(shouldFire) {
                fire()
                overlayAnimation.restart()
            }
        }
    }

    controls: Component {
        Column {
            anchors.fill: parent
            BoundSlider {
                text: "Rate"
                minimumValue: 0.0e3
                maximumValue: 1.0e3
                unitScale: 1.0e3
                unit: "/ms"
                target: engine
                property: "rate"
            }
            FireOutputControl {
                target: engine
            }
        }
    }

    Image {
        anchors.fill: parent

        source: inhibitory ? inhibitoryImageSource : imageSource
        smooth: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: overlay
        anchors.fill: parent

        source: "qrc:/images/generators/generator_overlay.png"
        smooth: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
        opacity: 0
    }

    NumberAnimation {
        id: overlayAnimation
        target: overlay
        property: "opacity"
        from: 0.5
        to: 0
        duration: 200
        easing.type: Easing.OutQuad
    }

    Connector {
        visible: root.selected
        curveColor: inhibitory ? "#e41a1c" : "#6baed6"
        connectorColor: inhibitory ? "#e41a1c" : "#6baed6"
        onDropped: {
            root.droppedConnector(root, connector)
        }
    }
}
