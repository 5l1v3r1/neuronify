#ifndef KERNEL_H
#define KERNEL_H

#include <QQuickItem>
#include <vector>
#include <iostream>
#include <QImage>
#include <iomanip>
#include <limits>

#include "kernels/abstractkernelengine.h"

using namespace std;

class Kernel : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(int resolutionHeight READ resolutionHeight WRITE setResolutionHeight NOTIFY resolutionHeightChanged)
    Q_PROPERTY(int resolutionWidth READ resolutionWidth WRITE setResolutionWidth NOTIFY resolutionWidthChanged)
    Q_PROPERTY(QImage spatialImage READ spatialImage WRITE setSpatialImage NOTIFY imageChanged)
    Q_PROPERTY(AbstractKernelEngine* abstractKernelEngineType READ abstractKernelEngineType WRITE setAbstractKernelEngineType NOTIFY abstractKernelEngineTypeChanged)


public:
    Kernel();

public:
    enum spatialTypes{
        OffLeftRF,
        OffRightRF,
        OffTopRF,
        OffBottomRF,
        GaborRF
    };

    int resolutionHeight() const;
    int resolutionWidth() const;
    void recreate();


    //Kernel types:
//    void createOffLeft();
//    void createOffRight();
//    void createOffTop();
//    void createOffBottom();

    vector<vector<double> > spatial();
    AbstractKernelEngine* abstractKernelEngineType() const;
    QImage spatialImage() const;

public slots:
    void setResolutionHeight(int resolutionHeight);
    void setResolutionWidth(int resolutionWidth);
    void setSpatialImage(QImage spatialImage);
    void setAbstractKernelEngineType(AbstractKernelEngine* abstractKernelEngineType);

signals:
    void resolutionHeightChanged(int resolutionHeight);
    void resolutionWidthChanged(int resolutionWidth);
    void imageChanged(QImage spatialImage);
    void abstractKernelEngineTypeChanged(AbstractKernelEngine* abstractKernelEngineType);


private:
    AbstractKernelEngine* m_abstractKernelEngineType = nullptr;

protected:
    int m_resolutionHeight = 10;
    int m_resolutionWidth = 10;
    vector< vector <double>> m_spatial;
    QImage m_spatialImage;

};


#endif // KERNEL_H
