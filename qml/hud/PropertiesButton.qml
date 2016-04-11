import QtQuick 2.0

import ".."
import "../style"

Item {
    id: root

    signal clicked

    property bool revealed: true

    opacity: 0
    width: Style.touchableSize * 1.5
    height: width
    Image {
        anchors.centerIn: parent
        width: Style.touchableSize
        height: width

        fillMode: Image.PreserveAspectFit

        source: "qrc:/images/tools/properties.png"
    }

    MouseArea {
        anchors.fill: parent
        enabled: revealed
        onClicked: {
            root.clicked()
        }
    }

    states: State {
        when: revealed
        PropertyChanges {
            target: root
//            anchors.rightMargin: 0
            opacity: 1.0
        }
    }

    transitions: Transition {
        NumberAnimation {
//            property: "anchors.rightMargin"
            property: "opacity"
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }
}

