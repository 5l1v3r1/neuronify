import QtQuick 2.0
import "paths"
import "hud"
import Neuronify 1.0

Node {
    id: root
    objectName: "neuron"
    fileName: "Neuron.qml"

    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    property real rate: 1.0

    width: parent.width * 0.015
    height: width

    dumpableProperties: [
        "x",
        "y"
    ]

    engine: NodeEngine {
        fireOutput: 1.0

        onReceivedFire: {
            rate = stimulation
        }

        onStepped: {
            var shouldFire = (Math.random() < rate*dt)
            if(shouldFire) {
                fire()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "pink"
    }

    Connector {
        visible: root.selected
        onDropped: {
            root.droppedConnector(root, connector)
        }
    }
}
