import QtQuick 2.0
import QtMultimedia 5.0

import Neuronify 1.0

/*!
\qmltype Node
\brief The Node type is the base of all items in Neuronify.

Node is a visual QML item that holds all common properties of items in
Neuronify.
It inherits NodeBase, which is its C++ counterpart.

In principle, \l Node and NodeBase could be the same class, but because
\l GraphEngine and \l NodeEngine cannot know about a QML type, we need to split
them up.
This is because we wish to use some QML features to define the functionality
of \l Node (such as \l MouseArea dragging), that does not allow us to put all
functionality of \l Node in C++.

\sa NodeBase, NodeEngine
*/

NodeBase {
    id: root
    signal clicked(var entity, var mouse)
    signal clickedConnector(var entity, var mouse)
    signal dragStarted(var entity)
    signal dragEnded(var entity)
    signal droppedConnector(var poissonGenerator, var connector)
    signal fired
    property real snapGridSize: 1.0
    property var dragProxy
    property string label: ""
    property string objectName: "entity"
    property string fileName: "Entity.qml"
    property real radius: width * 0.5
    property bool selected: false
    property vector2d velocity
    property bool dragging: false
    property var copiedFrom
    property color color: "cyan"
    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    property Component controls
    property Item simulator
    property bool useDefaultMouseHandling: true
    property bool square: false
    property var removableChildren: [] // used by nodes such as TouchSensor that has child nodes
    property var dumpableProperties: [
        "x",
        "y",
        "label",
        "fileName"
    ]

    onEngineChanged: {
        if(engine) {
            engine.fired.connect(root.fired)
        }
    }

    engine: NodeEngine {
        onReceivedFire: {
        }
    }

    function resolveAlias(index) {
        return undefined;
    }

    function _basicSelfDump() {
        var outputString = "";
        var entityData = {};

        for(var i in dumpableProperties) {
            var propertyName = dumpableProperties[i];
//            entityData[propertyName] = root[propertyName];
            var sourceObject = root;
            var targetObject = entityData;
            var previousTargetObject = targetObject;
            var splits = propertyName.split(".");
            var subName = "";
            for(var j in splits) {
                subName = splits[j];
                sourceObject = sourceObject[subName];
                if(!targetObject[subName]) {
                    targetObject[subName] = {};
                }
                previousTargetObject = targetObject;
                targetObject = targetObject[subName];
            }
            previousTargetObject[subName] = sourceObject;
        }

        return entityData;
    }

    function dump() {
        return _basicSelfDump()
    }

    Rectangle{
        anchors.fill: labelBox
        color: "white"
        opacity: 0.5
        z: 98
    }

    Text {
        anchors.bottom: root.top
        id: labelBox
        z: 99
        text: qsTr(label)
    }

    Rectangle {
        id: selectionIndicator

        property color faintColor: Qt.rgba(0, 0.2, 0.4, 0.5)
        property color strongColor: Qt.rgba(0.4, 0.6, 0.8, 0.5)

        anchors.centerIn: root
        visible: root.selected

        color: "transparent"

        border.width: 2.0
        width: root.width + 12.0
        height: root.height + 12.0

        antialiasing: true
        smooth: true

        SequentialAnimation {
            running: selectionIndicator.visible
            loops: Animation.Infinite
            ColorAnimation { target: selectionIndicator; property: "border.color"; from: selectionIndicator.faintColor; to: selectionIndicator.strongColor; duration: 1000; easing.type: Easing.InOutQuad }
            ColorAnimation { target: selectionIndicator; property: "border.color"; from: selectionIndicator.strongColor; to: selectionIndicator.faintColor; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        enabled: useDefaultMouseHandling
        anchors.fill: parent
        drag.target: root.dragProxy

        onPressed: {
            root.dragging = true
            dragStarted(root)
        }

        onClicked: {
            root.clicked(root, mouse)
        }

        onReleased: {
            root.dragging = false
            dragEnded(root)
        }
    }
}

