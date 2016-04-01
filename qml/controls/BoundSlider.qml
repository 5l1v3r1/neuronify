import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQml 2.2
import QtGraphicalEffects 1.0

import "qrc:/qml/style"

Item {
    id: root

    property QtObject target: null
    property string property: ""
    property string text: ""
    property string unit: ""
    property int precision: 1
    property real unitScale: 1.0

    property real minimumValue: -1.0
    property real maximumValue: 1.0
    property real stepSize: 0.0

    property bool anyFocus: focus || textInput.focus

    readonly property string defaultState: "edit"

    focus: false

    state: defaultState

    width: parent.width
    height: Style.control.fontMetrics.height * 2

    function applyTextEdit() {
        root.focus = true
        root.state = "edit"
        sliderMouseArea.value = unitScale * Number.fromLocaleString(Qt.locale("en_US"), textInput.text);
    }

    function discardTextEdit() {
        root.focus = true
        root.state = "edit"
    }

    onAnyFocusChanged: {
        console.log("anyFocus: " + anyFocus)
        if(!anyFocus) {
            state = defaultState
        }
    }

    onStateChanged: {
        console.log("State: " + state)
    }

    Rectangle {
        id: backgroundRectangle
        anchors {
            fill: parent
            topMargin: 2
            bottomMargin: 2
        }
        radius: height / 2
        color: Style.color.background

        clip: true

        Rectangle {
            id: sliderRectangle
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * sliderMouseArea.fraction
            color: "lightgrey" // Style.color.foreground
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: sliderRectangle.width
                    height: sliderRectangle.height
                    Rectangle {
                        width: backgroundRectangle.width
                        height: backgroundRectangle.height
                        radius: backgroundRectangle.radius
                    }
                }
            }
        }

        Text {
            id: fullText
            anchors {
                left: parent.left
                leftMargin: backgroundRectangle.radius
                verticalCenter: parent.verticalCenter
            }
            text: root.text
            font: Style.control.font
        }

        Text {
            id: numberText
            anchors {
                right: parent.right
                rightMargin: backgroundRectangle.radius
                verticalCenter: parent.verticalCenter
            }
            text: sliderMouseArea.scaledValue.toLocaleString(Qt.locale("en_US"), "f", root.precision) + " " + root.unit
            font: Style.control.font
        }

        TextInput {
            id: textInput
            anchors {
                left: parent.left
                leftMargin: fullText.anchors.leftMargin
                verticalCenter: fullText.anchors.verticalCenter
            }
            font: fullText.font

            verticalAlignment: Text.AlignVCenter
            visible: false

            Keys.onEnterPressed: {
                root.applyTextEdit()
            }

            Keys.onReturnPressed: {
                root.applyTextEdit()
            }

            Keys.onEscapePressed: {
                root.discardTextEdit()
            }
        }

        Rectangle {
            id: borderRectangle
            color: "transparent"
            anchors.fill: parent
            radius: parent.radius
            border.width: Style.border.width
            border.color: Style.border.color
        }

        MouseArea {
            id: sliderMouseArea
            readonly property real fraction: (value - minimumValue) / range
            readonly property real range: Math.abs(maximumValue - minimumValue)
            readonly property real scaledValue: value / unitScale
            property real value: 0.0
            property real minimumValue: root.minimumValue
            property real maximumValue: root.maximumValue
            property real stepSize: root.stepSize
            property point previousPosition
            property point startPosition
            property bool moved: false

            anchors.fill: parent
            preventStealing: true

            onValueChanged: {
                var properValue = value;
                if(isNaN(properValue)) {
                    properValue = 0.0;
                }
                if(root.stepSize > 0.0) {
                    var steps = Math.round((properValue - minimumValue)/ root.stepSize);
                    properValue = steps * root.stepSize + minimumValue;
                }
                properValue = Math.max(minimumValue, Math.min(maximumValue, properValue));
                value = properValue;
            }

            onPositionChanged: {
                var startDelta = Qt.point(mouse.x - startPosition.x, mouse.y - startPosition.y);
                var delta = Qt.point(mouse.x - previousPosition.x, mouse.y - previousPosition.y);
                if(moved || Math.abs(startDelta.x / sliderMouseArea.width) > 0.01) {
                    var diff = delta.x / sliderMouseArea.width * range;
                    if(Math.abs(diff) > root.stepSize) {
                        value += delta.x / sliderMouseArea.width * range;
                        moved = true;
                        previousPosition = Qt.point(mouse.x, mouse.y);
                    }
                }
            }

            onPressed: {
                startPosition = Qt.point(mouse.x, mouse.y);
                previousPosition = startPosition;
                moved = false;
            }

            onReleased: {
                if(!moved) {
                    root.state = "textedit";
                    textInput.text = sliderMouseArea.scaledValue.toLocaleString(Qt.locale("en_US"), "f", root.precision);
                    textInput.selectAll();
                    textInput.forceActiveFocus();
                }
            }
        }
    }

    MouseArea {
        id: editMouseArea
        anchors.fill: parent
        onClicked: {
            console.log("Focus!")
            root.focus = true
            root.state = "edit"
        }
    }

    Binding {
        target: root.target
        property: root.property
        value: sliderMouseArea.value
    }
    Binding {
        target: sliderMouseArea
        property: "value"
        value: root.target[root.property]
    }

    Gradient {
        id: grad
        GradientStop { position: 0.0; color: Style.color.foreground }
        GradientStop { position: 1.0; color: Style.color.border }
    }

    states: [
        State {
            name: "textedit"
            PropertyChanges {
                target: fullText
                visible: false
            }
            PropertyChanges {
                target: numberText
                visible: false
            }
            PropertyChanges {
                target: textInput
                visible: true
                focus: true
            }
            PropertyChanges {
                target: backgroundRectangle
                color: Style.color.foreground
            }
            PropertyChanges {
                target: sliderMouseArea
                enabled: false
            }
            PropertyChanges {
                target: editMouseArea
                enabled: false
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: sliderRectangle
                visible: true
                gradient: grad
            }
            PropertyChanges {
                target: sliderMouseArea
                enabled: true
            }
            PropertyChanges {
                target: editMouseArea
                enabled: false
            }
        },
        State {
            name: "view"
        }

    ]
}
