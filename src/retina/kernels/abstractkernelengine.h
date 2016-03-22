#ifndef KERNELABSTRACTENGINE_H
#define KERNELABSTRACTENGINE_H

#include <QQuickItem>
#include <vector>
#include <iostream>

using namespace std;

const static long double pi = 3.141592653589793238462643383279502884L;

class AbstractKernelEngine: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(int resolutionHeight READ resolutionHeight WRITE setResolutionHeight NOTIFY resolutionHeightChanged)
    Q_PROPERTY(int resolutionWidth READ resolutionWidth WRITE setResolutionWidth NOTIFY resolutionWidthChanged)


public:
    AbstractKernelEngine();

    virtual void createKernel(vector<vector<double> > * spatial) = 0;
    int resolutionHeight() const;
    int resolutionWidth() const;

public slots:
    void setResolutionHeight(int resolutionHeight);
    void setResolutionWidth(int resolutionWidth);

signals:
    void resolutionHeightChanged(int resolutionHeight);
    void resolutionWidthChanged(int resolutionWidth);

protected:
    int m_resolutionHeight = 80;
    int m_resolutionWidth = 80;
};

#endif // KERNELABSTRACTENGINE_H
