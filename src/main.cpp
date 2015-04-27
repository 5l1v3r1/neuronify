#include "engine/nodebase.h"
#include "engine/nodeengine.h"
#include "engine/edge.h"
#include "engine/neuronengine.h"
#include "engine/current.h"
#include "engine/graphengine.h"
#include "engine/retinaengine.h"
#include "engine/retinapainter.h"
#include "engine/videosurface.h"
#include "currents/passivecurrent.h"
#include "currents/adaptationcurrent.h"
#include "io/fileio.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QTextStream>
#include <QtQml>


int main(int argc, char *argv[])
{
    qmlRegisterType<FileIO>("Neuronify", 1, 0, "FileIO");

    qmlRegisterType<NodeBase>("Neuronify", 1, 0, "NodeBase");
    qmlRegisterType<NodeEngine>("Neuronify", 1, 0, "NodeEngine");
    qmlRegisterType<Edge>("Neuronify", 1, 0, "Edge");
    qmlRegisterType<GraphEngine>("Neuronify", 1, 0, "GraphEngine");

    qmlRegisterType<NeuronEngine>("Neuronify", 1, 0, "NeuronEngine");
    qmlRegisterType<RetinaEngine>("Neuronify", 1, 0, "RetinaEngine");
    qmlRegisterType<RetinaPainter>("Neuronify", 1, 0, "RetinaPainter");
    qmlRegisterType<VideoSurface>("Neuronify", 1, 0, "VideoSurface");

    qmlRegisterType<Current>("Neuronify", 1, 0, "Current");
    qmlRegisterType<PassiveCurrent>("Neuronify", 1, 0, "PassiveCurrent");
    qmlRegisterType<AdaptationCurrent>("Neuronify", 1, 0, "AdaptationCurrent");

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
