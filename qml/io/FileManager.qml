import QtQuick 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import Neuronify 1.0

/*!
\qmltype FileManager
\inqmlmodule Neuronify
\ingroup neuronify-io
\brief A type to contain the save/load features

Neuronify saves configurations by storing the javascript code needed to create
the network, and loads files by evaluating the generated and saved js code.

The read/write part is done in \l{FileIO}, while this object just treats the file
as a js string.
*/

Item {
    signal loadState(var fileUrl)

    property GraphEngine graphEngine: null
    property var workspace: null
    property var otherItems: []

    function showSaveDialog() {
        saveFileDialog.visible = true
    }

    function showLoadDialog() {
        loadFileDialog.visible = true
    }

    function objectify(obj) {
        if(obj.isAlias) {
            return obj.aliasInfo();
        }
        var result = {};
        for(var i in obj.savedProperties) {
            var properties = obj.savedProperties[i].dump();
            for(var name in properties) {
                var prop = properties[name];
                if(typeof(prop) === "object") {
                    result[name] = objectify(prop);
                } else {
                    result[name] = prop;
                }
            }
        }
        return result;
    }

    function saveState(fileUrl) {
        var nodes = graphEngine.nodes
        var edges = graphEngine.edges
        var nodeList = [];
        var edgeList = [];
        var otherList = [];

        console.log("Saving to " + fileUrl)

        var counter = 0
        for(var i in nodes) {
            var node = nodes[i];
            var dump = objectify(node);
            if(dump) {
                nodeList.push(dump);
            }
        }

        for(var i in edges) {
            var edge = edges[i]
            edgeList.push(edge.dump(i, graphEngine))
        }

        var workspaceProperties = workspace.dump();

        var result = {
            fileFormatVersion: 2,
            edges: edgeList,
            nodes: nodeList,
            workspace: workspaceProperties
        };
        var fileString = JSON.stringify(result);

        saveFileIO.source = fileUrl
        saveFileIO.write(fileString)
    }

    function read(fileUrl) {
        console.log("Reading file " + fileUrl)
        if(!fileUrl) {
            loadFileIO.source = "";
        } else {
            loadFileIO.source = fileUrl
        }
        var stateFile = loadFileIO.read()
        return stateFile
    }

    FileIO {
        id: loadFileIO
        source: "none"
        onError: console.log(msg)
    }

    FileIO {
        id: saveFileIO
        source: "none"
        onError: console.log(msg)
    }


//    Item {
//        id: saveFileDialog
//        visible : false
//        Grid{
//            id: saveFileDialogGrid
//            columns: 3
//            spacing: 2
//            CustomFileIcon{ }
//            CustomFileIcon{ }
//            CustomFileIcon{ }
//            CustomFileIcon{ }
//            CustomFileIcon{ }
//            CustomFileIcon{ }

//        }





//    FileDialog {
//        id: saveFileDialog
//        title: "Please enter a filename"
//        visible : false
//        selectExisting: false
//        nameFilters: Qt.platform.os === "osx" ? [] : ["Neuronify files (*.nfy)", "All files (*)"]

//        onAccepted: {
//            saveState(fileUrl)
//        }
//    }

    FileDialog {
        id: loadFileDialog
        title: "Please choose a file"
        visible : false
        nameFilters: Qt.platform.os === "osx" ? [] : ["Neuronify files (*.nfy)", "All files (*)"]

        onAccepted: {
            console.log("Load dialog accepted")
            loadState(fileUrl)
        }
    }
}

