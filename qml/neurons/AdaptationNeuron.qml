import QtQuick 2.0
import Neuronify 1.0

import ".."

Neuron {
    objectName: "adaptationNeuron"
    fileName: "neurons/AdaptationNeuron.qml"
    color: stimulation > 0.0 ? "green" : "yellow"
    engine: NeuronEngine {
        stimulation: 2.0
        PassiveCurrent {
        }
        AdaptationCurrent {
        }
    }
}

