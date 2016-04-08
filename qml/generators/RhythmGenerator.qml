import QtQuick 2.0
import QtQuick.Controls 1.0

import Neuronify 1.0

import "../paths"
import "../hud"
import "../controls"
import ".."

/*!
    \qmltype RhythmGenerator
    \inqmlmodule Neuronify
    \ingroup neuronify-generators
    \brief An spike generator which can supply input spikes to neurons.

    The Rhythm generator can be connected to neurons, and will then supply the neurons with spikes in regular intervals.
    The generator has a control panel where you can adjust the firing rate and stimulation output, as
    well as whether or not the generated spikes are inhibitory or excitatory.
*/

Node {
    id: root

    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    // TODO fireoutput engine
    readonly property bool inhibitory: false
    property url imageSource: "qrc:/images/generators/rhythm_generator_excitatory.png"
    property url inhibitoryImageSource: "qrc:/images/generators/rhythm_generator_inhibitory.png"

    property alias rate: engine.rate

    savedProperties: PropertyGroup {
        property alias engine: engine
    }

    objectName: "rhythmGenerator"
    fileName: "generators/RhythmGenerator.qml"

    width: 62
    height: 62
    color: inhibitory ? "#e41a1c" : "#6baed6"
    canReceiveConnections: false

    engine: NodeEngine {
        id: engine
        property real rate: 0.5e3
        property real timeSinceFiring: 0.0

        savedProperties: PropertyGroup {
            property alias rate: engine.rate
        }

        onStepped: {
            timeSinceFiring+=dt
            var shouldFire = (timeSinceFiring > 1./rate);
            if(shouldFire) {
                fire()
                overlayAnimation.restart()
            }
        }

        onFired:{
            timeSinceFiring = 0.0
        }
    }

    controls: Component {
        PropertiesPage {
            title: "Rhythm generator"
            BoundSlider {
                target: engine
                property: "rate"
                text: "Rate"
                minimumValue: 0.0e3
                maximumValue: 1.0e3
                unitScale: 1.0e3
                unit: "/ms"
                stepSize: 1.0e1
                precision: 2

            }
            BoundSlider {
                target: engine
                property: "fireOutput"
                minimumValue: -500.0e-6
                maximumValue: 500.0e-6
                unitScale: 1e-6
                text: "Stimulation"
                unit: "uS"
                stepSize: 1.0e-6
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
    }
}
