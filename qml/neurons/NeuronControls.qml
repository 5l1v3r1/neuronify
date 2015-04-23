import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import Neuronify 1.0

import ".."

Item {
    id: neuronControlsRoot

    signal deleteClicked

    property NeuronEngine engine: null

    anchors.fill: parent

    Binding {
        target: engine
        property: "fireOutput"
        value: fireOutputSlider.value
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: "Synaptic output: " + engine.fireOutput.toFixed(1) + " mS "
        }

        Slider {
            id: fireOutputSlider
            minimumValue: 0.
            maximumValue: 10.
            stepSize: 0.1
            tickmarksEnabled: true
            Layout.fillWidth: true
            value: engine.fireOutput
        }

        Button {
            text: "Delete"
            Layout.fillWidth: true
            onClicked: {
                console.log("Calling deleteClicked signal!")
                deleteClicked()
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
