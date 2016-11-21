import QtQuick 2.0
import Neuronify 1.0
import "../../controls"

GaborKernelEngine{
    id: gaborEngine
    resolutionHeight: 20
    resolutionWidth: 20

    property Component controls: Component{
        Column{
            BoundSlider {
                target: gaborEngine
                property: "theta"
                minimumValue: 0.0
                maximumValue: Math.PI
                unitScale: Math.PI/180
                stepSize: Math.PI/8
                precision: 1
                text: "Orientation"
                unit: "degrees"
            }

        }

    }

    savedProperties: PropertyGroup {
        property alias theta: gaborEngine.theta
    }
}

