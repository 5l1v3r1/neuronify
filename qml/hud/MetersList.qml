import QtQuick 2.0

ListModel {
    ListElement {
        name: "Voltmeter"
        description: "Measures the voltage of neurons."
        source: "qrc:/qml/meters/Voltmeter.qml"
        imageSource: "qrc:/images/meters/voltmeter.png"
    }
    ListElement {
        name: "Raster plot"
        description: "Shows firing times of neurons"
        source: "qrc:/qml/meters/RasterPlot.qml"
        imageSource: "qrc:/images/meters/spikemeter.png"
    }
    ListElement {
        name: "Firing rate plot"
        description: "Shows firing rate of neurons"
        source: "qrc:/qml/meters/FiringRateMeter.qml"
        imageSource: "qrc:/images/meters/voltmeter.png"
    }
    ListElement {
        name: "Speaker"
        description: "Plays a sound when a connected object fires."
        source: "qrc:/qml/meters/Speaker.qml"
        imageSource: "qrc:/images/meters/speaker.png"
    }
}
