#ifndef GRAPHENGINE_H
#define GRAPHENGINE_H

#include <QQuickItem>

class NodeBase;
class EdgeBase;
class GraphEngine : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<NodeBase> nodes READ nodes)
    Q_PROPERTY(QQmlListProperty<EdgeBase> edges READ edges)
public:
    explicit GraphEngine(QQuickItem* parent = 0);
    ~GraphEngine();

    QQmlListProperty<NodeBase> nodes();
    QQmlListProperty<EdgeBase> edges();

    Q_INVOKABLE int nodeIndex(NodeBase* node) const;

public slots:
    void step(double dt);

    void addNode(NodeBase *node);
    void addEdge(EdgeBase *edge);

    void removeNode(NodeBase *node);
    void removeEdge(EdgeBase *edge);

private:
    QVector<NodeBase*> m_nodes;
    QVector<EdgeBase*> m_edges;

    friend class EdgeWrapper;
    friend class NodeWrapper;
};

void step(const QVector<NodeBase*> &nodes, const QVector<EdgeBase*> &edges, double dt);

#endif // GRAPHENGINE_H
