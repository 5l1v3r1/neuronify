#include "videosurface.h"

#include "androidmultimediautils.h"

#include <QDebug>
#include <QVideoSurfaceFormat>
#include <QVideoRendererControl>

/*!
\class VideoSurface
\inmodule Neuronify
\brief Converts the camera frame to a gray-scale image.
 */

VideoSurface::VideoSurface()
{
    connect(&m_probe, &QVideoProbe::videoFrameProbed, this, &VideoSurface::present);
}

VideoSurface::~VideoSurface()
{

}

void VideoSurface::setCamera(QObject* camera)
{
    if (m_camera == camera)
        return;

    m_camera = camera;
    QCamera *cameraObject = qvariant_cast<QCamera *>(m_camera->property("mediaObject"));
    if(cameraObject) {
#ifdef Q_OS_ANDROID
        qDebug() << "Setting probe source";
        bool sourceSuccess = m_probe.setSource(cameraObject);
        if(!sourceSuccess) {
            qWarning() << "Could not set probe source!";
        }
#else
        qDebug() << "Setting renderer control";
        m_rendererControl = cameraObject->service()->requestControl<QVideoRendererControl *>();
        if(m_rendererControl) {
            qDebug() << "Setting renderer surface";
            m_rendererControl->setSurface(this);
        }
#endif
    }

    emit cameraChanged(camera);
}

void VideoSurface::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    emit enabledChanged(enabled);
}


QList<QVideoFrame::PixelFormat> VideoSurface::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const
{
    qDebug() << "Pixel formats requested";
    QList<QVideoFrame::PixelFormat> pixelFormat;
    pixelFormat.append(QVideoFrame::Format_RGB24);
    pixelFormat.append(QVideoFrame::Format_NV21);

    return pixelFormat;
}

bool VideoSurface::present(const QVideoFrame &constFrame)
{
    if(!m_enabled) {
        return true;
    }
    QVideoFrame frame = constFrame;
#ifdef Q_OS_ANDROID
    if((m_frameCounter % 2) == 0) {
        frame.map(QAbstractVideoBuffer::ReadOnly);
        QSize frameSize = frame.size();
        int factor = 8;
        QSize newSize = QSize(frame.size().width() / factor, frame.size().height() / factor);
        QImage result(newSize, QImage::Format_ARGB32);
        qt_convert_NV21_to_ARGB32_grayscale_factor((const uchar *)frame.bits(),
                                  (quint32 *)result.bits(),
                                  frameSize.width(),
                                  frameSize.height(),
                                         factor);
        m_paintedImage = result;
        frame.unmap();
        emit gotImage(QRect());
    }
    m_frameCounter += 1;
    return true;
#else

    QVideoFrame myFrame = frame;
    myFrame.map(QAbstractVideoBuffer::ReadOnly);

    QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat());
    m_paintedImage = QImage(myFrame.bits(), myFrame.width(), myFrame.height(),
                     myFrame.bytesPerLine(), imageFormat);
    emit gotImage(QRect());
    return true;
#endif
}

QImage VideoSurface::paintedImage() const
{
    return m_paintedImage;
}

QObject *VideoSurface::camera() const
{
    return m_camera;
}

bool VideoSurface::enabled() const
{
    return m_enabled;
}

