import QtQuick 2.0
import Neuronify 1.0

import "qrc:/"
import "qrc:/qml/"
import "qrc:/qml/controls"
import "qrc:/qml/neurons"

BoundSlider {
    property NeuronEngine engine
    target: engine
    property: "threshold"
    text: "Firing threshold"
    unit: "mV"
    minimumValue: -50e-3
    maximumValue: 50e-3
    unitScale: 1e-3
    stepSize: 1e-4
    precision: 1
}
