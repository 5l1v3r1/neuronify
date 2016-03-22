import QtQuick 2.0
import Neuronify 1.0

import "../../controls"

KernelContainer {
    id: root
    property alias engine: engine

    GaborKernelEngine{
        id: engine
        resolutionHeight: root.resolutionHeight
        resolutionWidth: root.resolutionWidth
    }

}
