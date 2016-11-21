import QtQuick 2.6
import QtQuick.Controls 1.4

import Neuronify 1.0

import ".."
import "../controls"
import "../style"

Neuron {
    id: neuronRoot

    objectName: "leakyNeuron"
    filename: "neurons/LeakyNeuron.qml"
    imageSource: "qrc:/images/neurons/leaky.png"
    inhibitoryImageSource: "qrc:/images/neurons/leaky_inhibitory.png"

    property bool fakeInhibitory: neuronEngine.fakeFireOutput < 0

    onFakeInhibitoryChanged: {
        if(fakeInhibitory) {
            neuronRoot.inhibitory = true;
        }
    }

    savedProperties: PropertyGroup {
        property alias label: neuronRoot.label
    }

    engine: NeuronEngine {
        id: neuronEngine
        property real refractoryPeriod
        property real timeSinceFire: 1.0 / 0.0 // infinity

        savedProperties: PropertyGroup {
            property alias refractoryPeriod: neuronEngine.refractoryPeriod
            property alias resistance: leakyCurrent.resistance
        }

        onResettedProperties: {
            refractoryPeriod = 2.0e-3;
        }

        onStepped: {
            if(timeSinceFire < refractoryPeriod) {
                neuronEngine.enabled = false
            } else {
                neuronEngine.enabled = true
            }
            timeSinceFire += dt
        }

        onFired: {
            timeSinceFire = 0.0
        }

        LeakCurrent {
            id: leakyCurrent
        }
    }

    controls: Component {
        PropertiesPage {
            property string title: "Leaky neuron"
            property StackView stackView: Stack.view
            spacing: 0
            PropertiesItem {
                text: "Label"
                info: neuronRoot.label
                LabelControl {
                    neuron: neuronRoot
                }
            }

            PropertiesItem {
                text: "Membrane"
                info: "C<sub>m</sub>: " + (neuronEngine.capacitance * 1e9).toFixed(1) + " nF, " +
                      "R<sub>m</sub>: " + (leakyCurrent.resistance * 1e-3).toFixed(1) + " kΩ, "
                CapacitanceControl{
                    engine: neuronEngine
                }

                ResistanceControl{
                    current: leakyCurrent
                }

                SwitchControl{
                    id: voltageClampedSwitch
                    target: neuronEngine
                    property: "voltageClamped"
                    checkedText: "Limit voltage"
                    uncheckedText: "Don't limit voltage"
                }

                BoundSlider {
                    enabled: voltageClampedSwitch.checked
                    text: "Minimum voltage"
                    unit: "mV"
                    unitScale: 1e-3
                    minimumValue: -200.0e-3
                    maximumValue: 200.0e-3
                    target: neuronEngine
                    property: "minimumVoltage"
                }

                BoundSlider {
                    enabled: voltageClampedSwitch.checked
                    text: "Maximum voltage"
                    unit: "mV"
                    unitScale: 1e-3
                    minimumValue: -200.0e-3
                    maximumValue: 200.0e-3
                    target: neuronEngine
                    property: "maximumVoltage"
                }

                Text {
                    property real timeConstant: neuronEngine.capacitance * leakyCurrent.resistance * 1e3
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    font: Style.control.font
                    text: "With these properties, the time constant is " +
                          timeConstant.toFixed(1) + " ms."
//                          "For a neuron with surface area ... this is " +
//                          "equivalent to ..."
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }

            PropertiesItem {
                text: "Potentials"
                info: "V<sub>r</sub>: " + (neuronEngine.restingPotential * 1e3).toFixed(1) + " mV, " +
                      "V<sub>reset</sub>: " + (neuronEngine.initialPotential * 1e3).toFixed(1) + " mV, " +
                      "V<sub>thres</sub>: " + (neuronEngine.threshold * 1e3).toFixed(1) + " mV "
                RestingPotentialControl{
                    id: restingPotentialControl
                    engine: neuronEngine
                }

                InitialPotentialControl{
                    engine: neuronEngine
                }

                ThresholdControl{
                    engine: neuronEngine
                }
            }

            PropertiesItem {
                text: "Synapse"
                info: (switchControl.checked ?
                           switchControl.checkedText : switchControl.uncheckedText)
                      + " , " + "τ<sub>r</sub>: "
                      + (neuronEngine.refractoryPeriod * 1e3).toFixed(1) + " ms, "
                SwitchControl{
                    id: switchControl
                    target: neuronRoot
                    property: "inhibitory"
                    checkedText: "Inhibitory"
                    uncheckedText: "Excitatory"

                }

                RefractoryPeriodControl{
                    engine: neuronEngine
                }

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    font: Style.control.font
                    text: "The synaptic weights can be changed by selecting " +
                          "the synapses. "+
                          "Just touch the lines connecting the neurons."
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

            }

            ConnectMultipleControl {
                node: neuronRoot
            }

            ResetControl {
                engine: neuronEngine
            }
        }
    }

}

