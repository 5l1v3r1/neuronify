import QtQuick 2.0
import QtQuick.Controls 1.0

import Neuronify 1.0


import "qrc:/"
import "qrc:/qml/"
import "qrc:/qml/controls"
import "../style"


Neuron {
    id: neuronRoot


    objectName: "adaptationNeuron"
    filename: "neurons/AdaptationNeuron.qml"
    imageSource: "qrc:/images/neurons/adaptive.png"
    inhibitoryImageSource: "qrc:/images/neurons/adaptive_inhibitory.png"

    engine: NeuronEngine {
        id: neuronEngine
        PassiveCurrent {
            id: passiveCurrent
        }
        AdaptationCurrent {
            id: adaptationCurrent
            adaptation: 50.0e-6
            timeConstant: 300.0e-3
        }

        savedProperties: PropertyGroup {
            property alias adaptation: adaptationCurrent.adaptation
            property alias timeConstant: adaptationCurrent.timeConstant
        }
    }

    controls: Component {
        PropertiesPage {
            property string title: "Adaptive neuron"
            LabelControl {
                neuron: neuronRoot
            }
            SwitchControl{
                id: switchControl
                target: neuronRoot
                property: "inhibitory"
                checkedText: "Inhibitory"
                uncheckedText: "Excitatory"

            }
            AdaptationControl{
                current: adaptationCurrent
            }
            AdaptationTimeConstantControl{
                current: adaptationCurrent
            }

            Text {
                text: "Fixed parameters:"
                font: Style.control.font
                color: Style.text.color
            }

            Text {
                id: subText
                font: Style.control.subText.font
                color: Style.control.subText.color
                text: "Vr: " +
                      (neuronEngine.restingPotential * 1e3).toFixed(1)
                      + " mV, " +
                      "Vi: " +
                      (neuronEngine.initialPotential * 1e3).toFixed(1)
                      + " mV, " +
                      "Vt: " +
                      (neuronEngine.threshold * 1e3).toFixed(1)
                      + " mV \n" +
                      "C: " +
                      (neuronEngine.capacitance * 1e9).toFixed(1)
                      + " nF, " +
                      "R: " +
                      (passiveCurrent.resistance * 1e-3).toFixed(1)
                      + " kΩ, \n" +
                      "τr: "+
                      0
                      + " ms, "
            }

            spacing: 10
            RestPotentialControl{
                engine: neuronEngine
            }

        }
    }
}

