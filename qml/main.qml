import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: applicationWindow1
    visible: true
    width: 1136
    height: 640
    title: qsTr("Neuronify")

    Neuronify {
        anchors.fill: parent
    }


}
