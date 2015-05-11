#include "retinaengine.h"

#include <QPainter>
#include <QVideoRendererControl>
#include <random>

RetinaEngine::RetinaEngine()
{
}

RetinaEngine::~RetinaEngine()
{
}

void RetinaEngine::receivedImage()
{
    if(!m_receptiveField){
        return;
    }

    int resolutionHeight = m_receptiveField->resolutionHeight();
    int resolutionWidth = m_receptiveField->resolutionWidth();
    m_stim.resize(resolutionWidth);
    for(int i = 0; i < resolutionWidth; i++){
        m_stim.at(i).resize(resolutionHeight,0.0);
    }

    m_image = m_videoSurface->image();
    m_image =  m_image.scaled(resolutionWidth,resolutionHeight);


    for(int i = 0; i < m_image.width(); i++){
        for(int j = 0; j < m_image.height(); j++){
#ifdef Q_OS_ANDROID
            int gray = m_image.pixel(i,j);
#else
            int gray = qGray(m_image.pixel(i,j));
            QRgb color = qRgb(gray, gray, gray);
            m_image.setPixel(i,j,color);
#endif
            m_stim.at(i).at(j) = gray-126.;
        }
    }

    calculateFiringRate();
    update();
}

void RetinaEngine::calculateFiringRate()
{
    if(!m_receptiveField){
        return;
    }

    m_receptiveFieldShape = m_receptiveField->rf();
    int resolutionHeight= m_receptiveField->resolutionHeight();
    int resolutionWidth = m_receptiveField->resolutionWidth();

    m_firingRate = 0.0;
    for(int i = 0; i < resolutionWidth; i++){
        for(int j = 0; j < resolutionHeight; j++){
            m_firingRate += m_stim.at(i).at(j) *  m_receptiveFieldShape.at(i).at(j);
        }
    }
    int size = resolutionHeight*resolutionWidth;
    m_firingRate /= size;
    if(m_firingRate < 0){
        m_firingRate = 0;
    }
}



void RetinaEngine::stepEvent(double dt)
{
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0,1);

    double shouldFire = (dis(gen) < m_firingRate*dt);
    if(shouldFire){
        fire();
    }


}


void RetinaEngine::setVideoSurface(VideoSurface *videoSurface)
{

    if (m_videoSurface == videoSurface)
        return;
    if(m_videoSurface){
        disconnect(m_videoSurface, &VideoSurface::gotImage, this, &RetinaEngine::receivedImage);
    }
    m_videoSurface = videoSurface;
    if(m_videoSurface){
        connect(m_videoSurface, &VideoSurface::gotImage, this, &RetinaEngine::receivedImage);
    }
    emit videoSurfaceChanged(videoSurface);
}





void RetinaEngine::setReceptiveField(ReceptiveField *recField)
{
    if (m_receptiveField == recField)
        return;

    m_receptiveField = recField;



    emit receptiveFieldChanged(recField);
}


QImage RetinaEngine::image() const
{
    return m_image;
}




ReceptiveField *RetinaEngine::receptiveField() const
{
    return m_receptiveField;
}

VideoSurface *RetinaEngine::videoSurface() const
{
    return m_videoSurface;
}








