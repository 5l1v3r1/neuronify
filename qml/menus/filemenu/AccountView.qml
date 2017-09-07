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

import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Item {
    function login() {
        Parse.login(userField.text, passwordField.text, function(response) {
            if(!response.sessionToken) {
                passwordField.ToolTip.show("Wrong username or password", 1000)
            }
        })
    }
    
    Column {
        visible: !Parse.loggedIn
        TextField {
            id: userField
            selectByMouse: true
            placeholderText: "Username or email"
        }
        
        TextField {
            id: passwordField
            echoMode: TextInput.Password
            selectByMouse: true
            placeholderText: "Password"
            onAccepted: {
                login()
            }
        }
        
        Button {
            Material.theme: Material.Light
            enabled: userField.text != "" && passwordField.text != ""
            width: 120
            text: "Log in"
            onClicked: {
                login()
            }
        }
    }
    
    Button {
        Material.theme: Material.Light
        visible: Parse.loggedIn
        width: 120
        text: "Log out"
        onClicked: {
            Parse.logout()
        }
    }
}
