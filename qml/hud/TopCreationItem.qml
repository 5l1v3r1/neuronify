import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import "qrc:/qml/style"

Item {
    id: root
    property string objectName: "CreationItem"

    signal dropped(var fileUrl, var properties, var controlParent)
    signal clicked(var mouse)

//    default property alias subChildren: creationControl.children

    property string name: "test long text with long name"
    property string description: ""
    property url source: ""
    property url imageSource: "qrc:/images/neurons/leaky.png"
    property Item parentWhenDragging
    property bool dragActive: false
    property bool selected: false

    width: 64
    height: column.height

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(mouse)
        }
    }

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
        }
        spacing: 8

        MouseArea {
            id: mouseArea

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            width: parent.width * 0.6
            height: width

            drag.target: creationControl

            onClicked: {
                root.clicked(mouse)
            }

            onReleased: {
                creationControl.Drag.drop()
            }

            Item {
                id: creationControl

                property alias creationItem: root

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                width: mouseArea.width
                height: width

                Drag.hotSpot.x: 32
                Drag.hotSpot.y: 32
                Drag.active: mouseArea.drag.active
                Drag.keys: ["lol"]

                states: State {
                    when: mouseArea.drag.active
                    ParentChange { target: creationControl; parent: root.parentWhenDragging }
                    AnchorChanges { target: creationControl; anchors.horizontalCenter: undefined; anchors.verticalCenter: undefined }
                    PropertyChanges {
                        target: root
                        dragActive: true
                    }
                }

                Image {
                    id: image
                    visible: false
                    anchors.fill: parent
                    source: imageSource
                    fillMode: Image.PreserveAspectFit
                    antialiasing: true
                    smooth: true
                    asynchronous: true
                }

                DropShadow {
                    anchors.fill: image
                    source: image
                    samples: 17
                    radius: 8
                    horizontalOffset: 1
                    verticalOffset: 4
                    color: Qt.hsla(0.0, 0.0, 0.0, 0.2)
                    smooth: true
                    antialiasing: true
                    visible: !root.selected
                }

                Glow {
                    anchors.fill: image
                    source: image
                    samples: 17
                    radius: 8
                    color: Qt.rgba(0.5, 0.8, 0.8, 1.0)
                    smooth: true
                    antialiasing: true
                    visible: root.selected
                }
            }

        }

        Text {
            id: text
            anchors {
                left: parent.left
                right: parent.right
            }
            color: Style.mainDesktop.text.color
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: root.name
        }

        Item {
            width: 1
            height: 8
        }
    }
}

