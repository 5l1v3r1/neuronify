import QtQuick 2.0

import Neuronify 1.0

NeuronEngineBase {
    id: engine
    savedProperties: PropertyGroup {
        property alias fireOutput: engine.fireOutput
        property alias initialPotential: engine.initialPotential
        property alias restingPotential: engine.restingPotential
        property alias threshold: engine.threshold
        property alias voltage: engine.voltage
        property alias capacitance: engine.capacitance
        property alias synapticConductance: engine.synapticConductance
        property alias synapticTimeConstant: engine.synapticTimeConstant
        property alias synapticPotential: engine.synapticPotential
    }
}
