import QtQuick 2.0
import QtQuick.Controls 1.3
import QtMultimedia 5.4
import Neuronify 1.0
import "../paths"
import "../hud"
import "../controls"
import ".."
import "../paths"
import "../hud"
import "../controls"
import ".."



/*!
\qmltype Retina
\inqmlmodule Neuronify
\ingroup neuronify-sensors
\brief Visual sensor that can be connected to neurons to generate activity
based on the receptive field of the sensor and the visual stimuli captured by
the camera.
*/

Node {
    id: root
    objectName: "retina"
    fileName: "sensors/Retina.qml"
    square: true


    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    property VideoSurface videoSurface: null;
    property int fieldIndex: 0
    property int viewIndex: 0
    property string kernelType: "kernels/GaborKernel.qml"
    property alias sensitivity: retinaEngine.sensitivity
    property alias plotKernel: retinaEngine.plotKernel


    color: "#0088aa"
    width: 240
    height: 180
    canReceiveConnections: false

    dumpableProperties: [
        "x",
        "y",
        "kernelType",
        "sensitivity",
        "plotKernel"
    ]

    onVideoSurfaceChanged: {
        if(!videoSurface){
            return
        }
        if(!videoSurface.camera.ActiveState){
            videoSurface.camera.start()
        }
    }

    Loader{
        id: kernelLoader
        source: root.kernelType
    }

    Kernel{
        id:kernel
        resolutionHeight : kernelLoader.item ?
                               kernelLoader.item.resolutionHeight: 80
        resolutionWidth : kernelLoader.item ?
                              kernelLoader.item.resolutionWidth : 80
        abstractKernelEngineType: kernelLoader.item ?
                                      kernelLoader.item.engine : null

        imageAlpha: 225
    }

    engine: RetinaEngine {
        id: retinaEngine
        kernel: kernel
        videoSurface: root.videoSurface
        plotKernel: true
    }

    controls: Component {
        Column {
            anchors.fill: parent

            Component.onCompleted: {
                for(var i = 0; i < fieldTypes.count; i++) {
                    var item = fieldTypes.get(i)
                    if(Qt.resolvedUrl(item.name) ===
                            Qt.resolvedUrl(root.kernelType)) {
                        comboBox.currentIndex = i
                        break
                    }
                }
            }


            Text {
                text: "Receptive Field: "
            }
            ComboBox {
                id: comboBox
                width: 200
                model: fieldTypes
                property bool created: false

                onChildrenChanged: {
                    if(!currentIndex+1){
                        currentIndex = fieldIndex
                    }
                }

                onCurrentIndexChanged: {
                    if(created){
                        kernelType = model.get(currentIndex).name
                        fieldIndex = currentIndex
                    }else{
                        created = true
                        for(var i = 0; i < fieldTypes.count; i++) {
                            var item = fieldTypes.get(i)
                            if(Qt.resolvedUrl(item.name) ===
                                    Qt.resolvedUrl(root.kernelType)) {
                                comboBox.currentIndex = i
                                break
                            }
                        }
                    }
                }

            }

            CheckBox {
                id: inhibitoryCheckbox
                text: "Show receptive field"
                checked: retinaEngine.plotKernel
                onCheckedChanged: {
                    if(checked) {
                        retinaEngine.plotKernel = true
                    }else{
                        retinaEngine.plotKernel = false
                    }
                }
            }

            //Slider to change the sensitivity:
            Text {
                text: "Sensitivity: " + retinaEngine.sensitivity.toFixed(0)
            }
            BoundSlider {
                minimumValue: 1
                maximumValue: 50
                stepSize: 5
                target: retinaEngine
                property: "sensitivity"
            }

        }

    }

    ListModel {
        id: fieldTypes
        ListElement {text: "Orientation selective";
            name: "kernels/GaborKernel.qml"}
        ListElement {text: "Center-surround"; name: "kernels/DogKernel.qml"}
        ListElement {text: "OffLeft"; name: "kernels/OffLeftKernel.qml"}
        ListElement {text: "OffRight"; name: "kernels/OffRightKernel.qml"}
        ListElement {text: "OffTop"; name: "kernels/OffTopKernel.qml"}
        ListElement {text: "OffBottom"; name: "kernels/OffBottomKernel.qml"}
    }

    Rectangle {
        color: "#0088aa"
        anchors.fill: parent
        radius: 5
        border.width: 0.0
        border.color: "#80e5ff"
    }

    RetinaPainter {
        id: retinaPainter
        retinaEngine: retinaEngine
        anchors {
            fill: parent
            margins: 5
        }
        property bool plotKernel: true
    }

    ResizeRectangle {
    }

    Connector {
        visible: root.selected
        curveColor: "#0088aa"
        connectorColor: "#0088aa"
        onDropped: {
            root.droppedConnector(root, connector)
        }
    }
}


