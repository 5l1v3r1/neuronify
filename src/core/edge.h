#ifndef EDGE_H
#define EDGE_H

#include <QQuickItem>
#include <QPointer>

class NodeBase;
class Edge : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(NodeBase* itemA READ itemA WRITE setItemA NOTIFY itemAChanged)
    Q_PROPERTY(NodeBase* itemB READ itemB WRITE setItemB NOTIFY itemBChanged)

public:
    explicit Edge(QQuickItem *parent = 0);

    NodeBase* itemA() const;
    NodeBase* itemB() const;

signals:
    void itemAChanged(NodeBase* arg);
    void itemBChanged(NodeBase* arg);

public slots:
    void setItemA(NodeBase* arg);
    void setItemB(NodeBase* arg);

private:
    QPointer<NodeBase> m_itemA;
    QPointer<NodeBase> m_itemB;
};

#endif // EDGE_H
