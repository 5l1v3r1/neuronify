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

Flickable {
    id: root

    signal itemClicked(var simulationData)

    contentHeight: column.height + 64
    clip: true
    
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}
    
    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
        }
        
        spacing: 16
        
        Component.onCompleted: {
            communityProgressBar.processCount += 1
            Firebase.get('simulations.json', function(response) {
                communityProgressBar.processCount -= 1
                console.log("Model", JSON.stringify(response))

                communityRepeater.model = Firebase.createModel(response)
            })
        }
        
        ProgressBar {
            id: communityProgressBar
            
            property int processCount: 0
            
            indeterminate: true
            visible: processCount > 0
        }

        DownloadManager {
            id: downloadManager
        }

        Flow {
            id: flow
            anchors {
                left: parent.left
                right: parent.right
            }

            spacing: 16

            Repeater {
                id: communityRepeater
                delegate: StoreItem {
                    property var objectData

                    Component.onCompleted: {
                        console.log("ModelData", JSON.stringify(modelData))
                        communityProgressBar.processCount += 1
                        objectData = modelData
                        name = modelData.name
                        description = modelData.description
                        Firebase.cachedDownload(
                            modelData.screenshot,
                            function (localFileName) {
                                communityProgressBar.processCount -= 1
                                imageUrl = localFileName
                            }
                        )
                    }

                    onClicked: {
                        itemClicked(objectData)
                    }
                }
            }
        }
    }
}
