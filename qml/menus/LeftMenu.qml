import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.3
import QtQuick.Particles 2.0
import QtQuick.Window 2.1

import QtCharts 2.1
import QtMultimedia 5.5
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.1
import Qt.labs.platform 1.0

import Neuronify 1.0
import CuteVersioning 1.0
import QtGraphicalEffects 1.0

import "qrc:/qml/backend"
import "qrc:/qml/controls"
import "qrc:/qml/hud"
import "qrc:/qml/io"
import "qrc:/qml/menus/filemenu"
import "qrc:/qml/menus/mainmenu"
import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Rectangle {
    id: root
    
    property real textOpacity: 1.0

    signal newClicked()
    signal saveClicked()
    signal openClicked()
    signal uploadClicked()
    signal communityClicked()

    signal accountClicked()
    signal settingsClicked()
    
    Material.theme: Material.Dark

    color: Material.primary
    z: 40
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    
    RowLayout {
        id: menuColumn
        anchors {
            fill: parent
            leftMargin: 24
            rightMargin: 8
            topMargin: 10
            bottomMargin: 8
        }
        spacing: 8
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "New"
            icon.name: "create"
            icon.category: "content"
            duration: 200
            onClicked: {
                newClicked()
            }
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Save"
            icon.name: "save"
            icon.category: "content"
            duration: 250
            onClicked: {
                saveClicked()
            }
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Open"
            icon.name: "folder_open"
            icon.category: "file"
            duration: 300
            onClicked: {
                openClicked()
            }
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Upload"
            icon.name: "cloud_upload"
            icon.category: "file"
            duration: 350
            onClicked: {
                uploadClicked()
            }
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Get more"
            icon.name: "cloud_download"
            icon.category: "file"
            duration: 400
            onClicked: {
                communityClicked()
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Account"
            icon.name: "account_circle"
            icon.category: "action"
            duration: 300
            onClicked: {
                accountClicked()
            }
        }
        MaterialButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumWidth: 48
            Layout.maximumWidth: parent.height
            state: mouseArea.containsMouse ? "" : "discrete"
            text: "Settings"
            icon.name: "settings"
            icon.category: "action"
            duration: 200
            onClicked: {
                settingsClicked()
            }
        }
    }
    
    states: [
        State {
            name: "small"
            PropertyChanges { target: root; width: 72 }
            PropertyChanges { target: logoTextCopy; opacity: 0.0 }
            PropertyChanges { target: root; textOpacity: 0.0 }
        },
        State {
            name: "hidden"
            //                AnchorChanges {
            //                    target: leftMenu
            //                    anchors {
            //                        left: undefined
            //                        right: parent.left
            //                    }
            //                }
        }
        
    ]
    
    transitions: [
        Transition {
            NumberAnimation {
                target: root
                properties: "width,textOpacity"
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: leftMenuShadow
                properties: "opacity"
                duration: 0
            }
            AnchorAnimation {
                duration: 0
            }
            NumberAnimation {
                target: logoTextCopy
                property: "opacity"
                duration: 400
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "hidden"
            to: ""
            AnchorAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
