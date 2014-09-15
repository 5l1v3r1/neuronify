import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Rectangle {
    id: simulatorRoot

    property real lastOrganizeTime: Date.now()
    property var compartments: []
    property var voltmeters: []
    property var voltmeterConnections: []
    property var compartmentConnections: []

    Component.onCompleted: {
        var previousCompartment = undefined
        var previousCompartment2 = undefined
        for(var i = 0; i < 10; i++) {
            var compartment = createCompartment({x: 200 + i * 100, y: 200 + (Math.random()) * 10})
            if(previousCompartment) {
                connectCompartments(previousCompartment, compartment)
            }
            //            if(previousCompartment2) {
            //                createConnection(previousCompartment2, compartment)
            //            }
            previousCompartment2 = previousCompartment
            previousCompartment = compartment
        }
    }

    function deleteCompartment(compartment) {
        disconnectCompartment(compartment)
        var compartmentsNew = simulatorRoot.compartments
        if(compartmentControls.compartment === compartment) {
            compartmentControls.compartment = null
        }
        var compartmentIndex = compartmentsNew.indexOf(compartment)
        if(compartmentIndex > -1) {
            compartmentsNew.splice(compartmentIndex, 1)
        }
        compartments = compartmentsNew
        compartment.destroy()
    }

    function deleteVoltmeter(voltmeter) {
        if(voltmeterControls.voltmeter === voltmeter) {
            voltmeterControls.voltmeter = null
        }
        var connectionsToRemove = []
        var connectionPlots = voltmeter.connectionPlots
        for(var i in connectionPlots) {
            var connectionPlot = connectionPlots[i]
            connectionsToRemove.push(connectionPlot.connection)
        }
        for(var i in connectionsToRemove) {
            deleteConnection(connectionsToRemove[i])
        }
        var voltmeterIndex = simulatorRoot.voltmeters.indexOf(voltmeter)
        if(voltmeterIndex > -1) {
            simulatorRoot.voltmeters.splice(voltmeterIndex, 1)
        }
        voltmeter.destroy()
    }

    function disconnectVoltmeter(voltmeter) {
        var connectionsToDelete = voltmeter.connectionPlots
        for(var i in connectionsToDelete) {
            var connection = connectionsToDelete[i]
            deleteConnection(connection)
        }
        var voltmeterConnectionsNew = voltmeterConnections
        for(var i in voltmeterConnections) {
            var voltmeterConnection = voltmeterConnections[i]
            if(voltmeterConnection.targetCompartment === voltmeter) {
                voltmeterConnectionsNew.splice(voltmeterConnections.indexOf(voltmeterConnection), 1)
                voltmeterConnection.destroy()
            }
        }
        voltmeterConnections = voltmeterConnectionsNew
    }

    function deleteConnection(connection) {
        var connectionIndex = compartmentConnections.indexOf(connection)
        if(connectionIndex > -1) {
            compartmentConnections.splice(connectionIndex, 1)
        }
        var voltmeterConnectionIndex = voltmeterConnections.indexOf(connection)
        if(voltmeterConnectionIndex > -1) {
            voltmeterConnections.splice(voltmeterConnectionIndex, 1)
        }
        connection.targetCompartment.removeConnection(connection)
        connection.sourceCompartment.removeConnection(connection)
        connection.destroy()
    }

    function disconnectCompartment(compartment) {
        var connectionsToDelete = compartment.connections
        compartment.connections = []
        var connectionsToDestroy = []
        for(var i in connectionsToDelete) {
            var connection = connectionsToDelete[i]
            deleteConnection(connection)
        }
        var voltmeterConnectionsNew = voltmeterConnections
        for(var i in voltmeterConnections) {
            var voltmeterConnection = voltmeterConnections[i]
            if(voltmeterConnection.targetCompartment === compartment) {
                voltmeterConnectionsNew.splice(voltmeterConnections.indexOf(voltmeterConnection), 1)
                voltmeterConnection.destroy()
            }
        }
        voltmeterConnections = voltmeterConnectionsNew
    }

    function isItemUnderConnector(item, source, connector) {
        var mouse2 = item.mapFromItem(source,
                                      connector.x + connector.width / 2,
                                      connector.y + connector.height / 2)
        var tolerance = connector.width / 2 + item.width * 0.1
        if(mouse2.x > -tolerance && mouse2.x < item.width + tolerance
                && mouse2.y > -tolerance && mouse2.y < item.height + tolerance) {
            return true
        } else {
            return false
        }
    }

    function compartmentUnderConnector(source, connector) {
        var compartment = undefined
        for(var i in compartments) {
            var targetCompartment = compartments[i]
            if(isItemUnderConnector(targetCompartment, source, connector)) {
                compartment = targetCompartment
            }
        }
        return compartment
    }

    function voltmeterUnderConnector(source, connector) {
        var voltmeter = undefined
        for(var i in voltmeters) {
            var targetVoltmeter = voltmeters[i]
            if(isItemUnderConnector(targetVoltmeter, source, connector)) {
                voltmeter = targetVoltmeter
            }
        }
        return voltmeter
    }

    function deselectAll() {
        deselectCompartmentConnections()
        deselectCompartments()
        deselectVoltmeters()
        deselectVoltmeterConnections()
    }

    function deselectAllInList(listName) {
        for(var i in listName) {
            var listObject = listName[i]
            listObject.selected = false
        }
    }

    function deselectVoltmeterConnections() {
        connectionControls.connection = null
        deselectAllInList(voltmeterConnections)
    }

    function deselectCompartmentConnections() {
        connectionControls.connection = null
        deselectAllInList(compartmentConnections)
    }

    function deselectCompartments() {
        compartmentControls.compartment = null
        deselectAllInList(compartments)
    }

    function deselectVoltmeters() {
        voltmeterControls.voltmeter = null
        deselectAllInList(voltmeters)
    }

    function clickedCompartment(compartment) {
        deselectAll()
        compartmentControls.compartment = compartment
        compartment.selected = true
    }

    function clickedConnection(connection) {
        deselectAll()
        connectionControls.connection = connection
        connection.selected = true
    }

    function clickedVoltmeter(voltmeter) {
        deselectAll()
        voltmeterControls.voltmeter = voltmeter
        voltmeter.selected = true
    }

    function createCompartment(properties) {
        var component = Qt.createComponent("Compartment.qml")
        var compartment = component.createObject(compartmentLayer, properties)
        compartment.dragStarted.connect(resetOrganize)
        compartment.clicked.connect(clickedCompartment)
        compartment.droppedConnectionCreator.connect(createConnectionToPoint)
        compartments.push(compartment)
        return compartment
    }

    function createVoltmeter(properties) {
        var component = Qt.createComponent("Voltmeter.qml")
        var voltmeter = component.createObject(compartmentLayer, properties)
        voltmeters.push(voltmeter)
        voltmeter.clicked.connect(clickedVoltmeter)
        return voltmeter
    }

    function createConnection(sourceObject, targetObject) {
        var connectionComponent = Qt.createComponent("Connection.qml")
        var connection = connectionComponent.createObject(connectionLayer, {
                                                              sourceCompartment: sourceObject,
                                                              targetCompartment: targetObject
                                                          })
        connection.clicked.connect(clickedConnection)
        return connection
    }

    function connectCompartments(sourceCompartment, targetCompartment) {
        var connection = createConnection(sourceCompartment, targetCompartment)
        sourceCompartment.connections.push(connection)
        targetCompartment.connections.push(connection)
        compartmentConnections.push(connection)
        return connection
    }

    function connectVoltmeter(compartment, voltmeter) {
        var connection = createConnection(compartment, voltmeter)
        voltmeter.addConnection(connection)
        voltmeterConnections.push(connection)
    }

    function createConnectionToPoint(sourceCompartment, connectionCreator) {
        var targetVoltmeter = voltmeterUnderConnector(sourceCompartment, connectionCreator)
        if(targetVoltmeter) {
            connectVoltmeter(sourceCompartment, targetVoltmeter)
            return
        }

        var targetCompartment = compartmentUnderConnector(sourceCompartment, connectionCreator)
        if(!targetCompartment || targetCompartment === sourceCompartment) {
            return
        }
        var connectionAlreadyExists = false
        for(var j in compartmentConnections) {
            var existingConnection = compartmentConnections[j]
            if((existingConnection.sourceCompartment === sourceCompartment && existingConnection.targetCompartment === targetCompartment)
                    || (existingConnection.targetCompartment === sourceCompartment && existingConnection.sourceCompartment === targetCompartment)) {
                connectionAlreadyExists = true
                break
            }
        }
        if(connectionAlreadyExists) {
            return
        }
        connectCompartments(sourceCompartment, targetCompartment)
        resetOrganize()
    }

    function resetOrganize() {
        lastOrganizeTime = Date.now()
        layoutTimer.start()
    }

    function organize() {
        var currentOrganizeTime = Date.now()
        var dt = Math.min(0.032, (currentOrganizeTime - lastOrganizeTime) / 1000.0)
        var springLength = simulatorRoot.width * 0.1
        var anyDragging = false

        for(var i in compartments) {
            var compartment = compartments[i]
            compartment.velocity = Qt.vector2d(0,0)
            if(compartment.dragging) {
                anyDragging = true
            }
        }

        for(var i in compartmentConnections) {
            var connection = compartmentConnections[i]
            var source = connection.sourceCompartment
            var target = connection.targetCompartment
            var xDiff = source.x - target.x
            var yDiff = source.y - target.y
            var length = Math.sqrt(xDiff*xDiff + yDiff*yDiff)
            var lengthDiff = length - springLength
            var xDelta = lengthDiff * xDiff / length
            var yDelta = lengthDiff * yDiff / length
            var kFactor = lengthDiff > 0 ? 0.015 : 0.007
            var k = kFactor * simulatorRoot.width
            if(!source.dragging) {
                source.velocity.x -= 0.5 * k * xDelta
                source.velocity.y -= 0.5 * k * yDelta
            }
            if(!target.dragging) {
                target.velocity.x += 0.5 * k * xDelta
                target.velocity.y += 0.5 * k * yDelta
            }
        }

        for(var i = 0; i < compartments.length; i++) {
            var minDistance = springLength * 0.8
            var compartmentA = compartments[i]
            for(var j = i + 1; j < compartments.length; j++) {
                var compartmentB = compartments[j]
                var xDiff = compartmentA.x - compartmentB.x
                var yDiff = compartmentA.y - compartmentB.y
                var length = Math.sqrt(xDiff*xDiff + yDiff*yDiff)
                if(length > minDistance) {
                    continue
                }

                var lengthDiff = length - minDistance
                var xDelta = lengthDiff * xDiff / length
                var yDelta = lengthDiff * yDiff / length
                var k = simulatorRoot.width * 0.005
                if(!compartmentA.dragging) {
                    compartmentA.velocity.x -= 0.5 * k * xDelta
                    compartmentA.velocity.y -= 0.5 * k * yDelta
                }
                if(!compartmentB.dragging) {
                    compartmentB.velocity.x += 0.5 * k * xDelta
                    compartmentB.velocity.y += 0.5 * k * yDelta
                }
            }
        }

        var maxAppliedVelocity = 0.0
        var maxVelocity = simulatorRoot.width * 1.0
        var minVelocity = simulatorRoot.width * 0.5
        for(var i in compartments) {
            var compartment = compartments[i]
            var velocity = Math.sqrt(compartment.velocity.x*compartment.velocity.x + compartment.velocity.y*compartment.velocity.y)
            if(velocity > maxVelocity) {
                compartment.velocity.x *= (maxVelocity / velocity)
            }

            maxAppliedVelocity = Math.max(maxAppliedVelocity, compartment.velocity.x*compartment.velocity.x + compartment.velocity.y*compartment.velocity.y)
            compartment.x += compartment.velocity.x * dt
            compartment.y += compartment.velocity.y * dt
        }

        if(maxAppliedVelocity < minVelocity && !anyDragging) {
            layoutTimer.stop()
        }

        lastOrganizeTime = currentOrganizeTime
    }

    width: 400
    height: 300
    color: "#f7fbff"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            deselectAll()
        }
    }

    Rectangle {
        id: compartmentCreator
        width: 60
        height: 40
        color: "#c6dbef"
        border.color: "#6baed6"
        border.width: 1.0

        Component.onCompleted: {
            resetPosition()
        }

        function resetPosition() {
            compartmentCreator.x = 0
            compartmentCreator.y = 0
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onReleased: {
                createCompartment({x: compartmentCreator.x, y: compartmentCreator.y})
                compartmentCreator.resetPosition()
            }
        }
    }

    Rectangle {
        id: voltmeterCreator
        width: 60
        height: 40
        color: "#deebf7"
        border.color: "#9ecae1"
        border.width: 1.0

        Component.onCompleted: {
            resetPosition()
        }

        function resetPosition() {
            voltmeterCreator.x = 0
            voltmeterCreator.y = 50
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onReleased: {
                createVoltmeter({x: voltmeterCreator.x, y: voltmeterCreator.y})
                voltmeterCreator.resetPosition()
            }
        }
    }

    Item {
        id: connectionLayer
        anchors.fill: parent
    }

    Item {
        id: compartmentLayer
        anchors.fill: parent
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: compartmentControls.compartment ? 0.0 : -width
            bottom: parent.bottom
        }
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutCubic
            }
        }

        color: "#f7fbff"
        width: parent.width * 0.2
        ColumnLayout {
            id: compartmentControls
            property Compartment compartment: null
            anchors.fill: parent
            spacing: 10
            onCompartmentChanged: {
                if(!compartmentControls.compartment) {
                    return
                }
                targetVoltageCheckbox.checked = compartment.forceTargetVoltage
            }

            Slider {
                id: polarizationSlider
                minimumValue: -100
                maximumValue: 100
                Layout.fillWidth: true
            }

            Text {
                text: "Polarization jump: " + polarizationSlider.value.toFixed(1) + " mV"
            }

            Button {
                id: polarizeButton
                Layout.fillWidth: true

                text: "Polarize!"
                onClicked: {
                    compartmentControls.compartment.voltage += polarizationSlider.value
                }
            }

            Button {
                id: resetButton
                Layout.fillWidth: true

                text: "Reset!"
                onClicked: {
                    for(var i in compartments) {
                        var compartment = compartments[i]
                        compartment.reset()
                    }
                }
            }

            CheckBox {
                id: targetVoltageCheckbox
                text: "Clamp voltage:" + targetVoltageSlider.value.toFixed(1) + " mV"
                onCheckedChanged: {
                    if(!compartmentControls.compartment) {
                        return
                    }
                    compartmentControls.compartment.forceTargetVoltage = checked
                    compartmentControls.compartment.targetVoltage = targetVoltageSlider.value
                }
            }

            Slider {
                id: targetVoltageSlider
                minimumValue: -100.0
                maximumValue: 100.0
                Layout.fillWidth: true
                onValueChanged: {
                    compartmentControls.compartment.targetVoltage = value
                }
            }

            Button {
                id: disconnectButton
                text: "Disconnect"
                Layout.fillWidth: true

                onClicked: {
                    simulatorRoot.disconnectCompartment(compartmentControls.compartment)
                }
            }

            Button {
                text: "Delete"
                Layout.fillWidth: true
                onClicked: {
                    simulatorRoot.deleteCompartment(compartmentControls.compartment)
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: voltmeterControls.voltmeter ? 0.0 : -width
            bottom: parent.bottom
        }
        color: "#f7fbff"
        width: parent.width * 0.2
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutCubic
            }
        }
        ColumnLayout {
            id: voltmeterControls
            property Voltmeter voltmeter: null

            anchors.fill: parent
            spacing: 10

            onVoltmeterChanged: {
                if(!voltmeterControls.voltmeter) {
                    return
                }
                var voltmeter = voltmeterControls.voltmeter
                switch(voltmeter.mode) {
                case "voltage":
                    voltageRadioButton.checked = true
                    break
                case "sodiumCurrent":
                    sodiumCurrentRadioButton.checked = true
                    break
                case "potassiumCurrent":
                    potassiumCurrentRadioButton.checked = true
                    break
                case "leakCurrent":
                    leakCurrentRadioButton.checked = true
                    break
                }
            }

            Text {
                text: "Mode:"
            }

            ExclusiveGroup {
                id: modeGroup
            }

            RadioButton {
                id: voltageRadioButton
                text: "Voltage"
                exclusiveGroup: modeGroup
                onCheckedChanged: {
                    if(checked) {
                        voltmeterControls.voltmeter.mode = "voltage"
                    }
                }
            }

            RadioButton {
                id: sodiumCurrentRadioButton
                text: "Sodium current"
                exclusiveGroup: modeGroup
                onCheckedChanged: {
                    if(checked) {
                        voltmeterControls.voltmeter.mode = "sodiumCurrent"
                    }
                }
            }

            RadioButton {
                id: potassiumCurrentRadioButton
                text: "Potassium current"
                exclusiveGroup: modeGroup
                onCheckedChanged: {
                    if(checked) {
                        voltmeterControls.voltmeter.mode = "potassiumCurrent"
                    }
                }
            }

            RadioButton {
                id: leakCurrentRadioButton
                text: "Leak current"
                exclusiveGroup: modeGroup
                onCheckedChanged: {
                    if(checked) {
                        voltmeterControls.voltmeter.mode = "leakCurrent"
                    }
                }
            }

            Button {
                text: "Delete"
                onClicked: {
                    simulatorRoot.deleteVoltmeter(voltmeterControls.voltmeter)
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: connectionControls.connection ? 0.0 : -width
            bottom: parent.bottom
        }
        color: "#f7fbff"
        width: parent.width * 0.2
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 350
                easing.type: Easing.InOutCubic
            }
        }
        ColumnLayout {
            id: connectionControls
            property Connection connection: null

            anchors.fill: parent
            spacing: 10

            onConnectionChanged: {
                if(!connectionControls.connection) {
                    return
                }

                axialConductanceSlider.value = connection.axialConductance
            }

            Text {
                text: "Axial conductance: " + axialConductanceSlider.value.toFixed(2)
            }

            Slider {
                id: axialConductanceSlider
                minimumValue: 0.01
                maximumValue: 100
                onValueChanged: {
                    if(!connectionControls.connection) {
                        return
                    }
                    connectionControls.connection.axialConductance = axialConductanceSlider.value
                }
            }

            Button {
                text: "Delete"
                onClicked: {
                    if(!connectionControls.connection) {
                        return
                    }
                    simulatorRoot.deleteConnection(connectionControls.connection)
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    Timer {
        id: layoutTimer
        interval: 24
        running: true
        repeat: true
        onTriggered: {
            organize()
        }
    }

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            for(var i in compartments) {
                var compartment = compartments[i]
                compartment.stepForward()
            }
            for(var i in compartments) {
                var compartment = compartments[i]
                compartment.finalizeStep()
            }
        }
    }
}
