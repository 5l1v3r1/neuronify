import QtQuick 2.0
import QtQuick.Controls 1.0

import Neuronify 1.0

import ".."
import "../controls"

/*!
    \qmltype ACClap
    \inqmlmodule Neuronify
    \ingroup neuronify-generators
    \brief An alternating current generator which can suply input to neurons

    The AC generator can be connected to neurons, and will then suply the neurons with current.
    The generator has a control panel where you can adjust the frequency and amplitude
*/

Node {

    filename: "generators/ACClamp.qml"

    width: 64
    height: 64
    color: "#dd5000"
    canReceiveConnections: false

    engine: NodeEngine {
        id: engine
        property real time: 0
        property real amplitude: 300e-12
        property real frequency: 50.0
        property real pi: 3.14159
        savedProperties: PropertyGroup {
            property alias amplitude: engine.amplitude
            property alias frequency: engine.frequency
            property alias time: engine.time
        }

        currentOutput: amplitude*Math.sin(2*pi*frequency*time)
        onStepped: {
            time += dt
        }

    }

    controls: Component {
        PropertiesPage {
            title: "AC clamp"
            BoundSlider {
                target: engine
                property: "amplitude"
                minimumValue: 0.0e-12
                maximumValue: 1000e-12
                unitScale: 1e-12
                unit: "pA"
                text: "Current amplitude"
                stepSize: 1e-12
            }
            BoundSlider {
                target: engine
                property: "frequency"
                minimumValue: 0.0
                maximumValue: 200.0
                unitScale: 1
                unit: "Hz"
                text: "Current frequency"
                stepSize: 1.
            }
        }
    }


    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/generators/ac_clamp.png"
    }

    Connector {
        curveColor: "#dd5000"
        connectorColor: "#dd5000"

    }
}
