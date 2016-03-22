import QtQuick 2.0
import "paths"
import "hud"
import Neuronify 1.0

Edge {
    id: connectionRoot
    signal clicked(var connection)
    signal aboutToDie(var connection)




    property bool selected: false
    property bool valid: (itemA && itemB) ? true : false
    property real conductance: 1.0
    property color color: valid ? itemA.color : "white"
    property real diffx: valid ? itemA.connectionPoint.x - itemB.connectionPoint.x : 0
    property real diffy: valid ? itemA.connectionPoint.y - itemB.connectionPoint.y : 0
    property real length: Math.sqrt(diffx*diffx + diffy*diffy)
    property real angle: Math.atan(diffy/diffx)*180/Math.PI
//    property real cx: valid ? itemB.connectionPoint.x + (connectionSpot.width + itemB.radius) * diffx / length : 0
//    property real cy: valid ? itemB.connectionPoint.y + (connectionSpot.width + itemB.radius) * diffy / length : 0
    property real cx: valid ? intersectX(): 0
    property real cy: valid ? intersectY(): 0
    property color _internalColor: connectionRoot.selected ? "#08306b" : connectionRoot.color
    property var customDump
    property Component controls: Component {
        ConnectionControls {
            connection: connectionRoot
            onDeleteClicked: {
                connectionRoot.destroy(1)
            }
        }
    }



    Component.onDestruction: {
        aboutToDie(connectionRoot)
    }


//    intersect.sign = sign = (value) ->
//      if value < 0 then -1 else 1

    function intersectX() {
        var x

        var dx = Math.abs(diffx)
        var dy = Math.abs(diffy)


        if (diffx <= 0 && diffy >= 0) {
            if (dx >= dy) {
                x = itemB.connectionPoint.x - itemB.width/2.
            } else {
                x = itemB.connectionPoint.x - itemB.width/2*dx/dy
            }

        } else if (diffx >= 0 && diffy >= 0) {

            x = itemB.connectionPoint.x
        } else if (diffx >= 0 && diffy <= 0) {


            x = itemB.connectionPoint.x
        } else {
            x = itemB.connectionPoint.x


        }

        return x

    }

    function intersectY() {
        var y

        var dx = Math.abs(diffx)
        var dy = Math.abs(diffy)


        if (diffx <= 0 && diffy >= 0) {
            if (dx >= dy) {
                y = itemB.connectionPoint.y + itemB.height/2.*dy/dx
            } else {
                y = itemB.connectionPoint.y + itemB.height/2.
            }

        } else if (diffx >= 0 && diffy >= 0) {
            y = itemB.connectionPoint.y


        } else if (diffx >= 0 && diffy <= 0) {
             y = itemB.connectionPoint.y

        } else {
            y = itemB.connectionPoint.y


        }
        return y

    }


    function dump(index, graphEngine) {
        if(customDump) {
            return customDump(index, graphEngine)
        }

        var outputString = ""
        var itemAEntityIndex = graphEngine.nodeIndex(itemA)
        if(itemAEntityIndex === -1) {
            console.error("Could not find index of node " + itemA + " in GraphEngine! Aborting dump!")
            return ""
        }

        var itemBEntityIndex = graphEngine.nodeIndex(itemB)
        if(itemBEntityIndex === -1) {
            console.error("Could not find index of node " + itemB + " in GraphEngine! Aborting dump!")
            return ""
        }
        outputString += "var connection" + index + " = connectEntities(entity" + itemAEntityIndex + ", entity" + itemBEntityIndex + ")\n"
        return outputString
    }

    Line {
        id: sCurve
        color: connectionRoot._internalColor
        startPoint: itemA ? Qt.point(itemA.connectionPoint.x, itemA.connectionPoint.y) : Qt.point(0,0)
        endPoint: Qt.point(cx, cy)
    }

    Item {
        x: sCurve.startPoint.x + height / 2 * Math.sin(rotation * Math.PI / 180)
        y: sCurve.startPoint.y - height / 2 * Math.cos(rotation * Math.PI / 180)

        transformOrigin: Item.TopLeft

        width: Qt.vector2d(sCurve.endPoint.x - sCurve.startPoint.x,
                           sCurve.endPoint.y - sCurve.startPoint.y).length()
        height: 40

        rotation: Math.atan2(sCurve.endPoint.y - sCurve.startPoint.y,
                             sCurve.endPoint.x - sCurve.startPoint.x) / Math.PI * 180

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onClicked: {
                if(connectionRoot.selected) {
                    mouse.accepted = false
                }

                connectionRoot.clicked(connectionRoot)
            }
        }
    }

    Rectangle {
        id: connectionSpot
        x: cx - width / 2
        y: cy - height / 2
        width: 10
        height: width

        radius: (itemA && itemA.engine) ? (itemA.engine.fireOutput > 0 ?  0 : width / 2.0) : width / 2.0;
        rotation: angle + 45
        color: connectionRoot._internalColor

        antialiasing: true
        smooth: true
    }
}
