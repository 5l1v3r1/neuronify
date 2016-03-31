import QtQuick 2.0
import "../../style"


Item {
    id: mainMenuView

    signal saveSimulationClicked
    signal loadSimulationClicked

    clip: true

    width: 200
    height: 100

    Column {
        anchors {
            left: parent.left
            leftMargin: Style.touchableSize
            verticalCenter: parent.verticalCenter
        }
        width: mainMenuView.width * 0.4
        spacing: mainMenuView.width * 0.02

        MenuButton {
            width: parent.width
            text: "Save simulation"
            onClicked: {
                saveView.isSave = true
                saveSimulationClicked()
            }
        }
        MenuButton {
            width: parent.width
            text: "Load simulation"
            onClicked: {
                saveView.isSave = false
                loadSimulationClicked()
            }
        }
    }
}
