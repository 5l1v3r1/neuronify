#include "sodiumcurrent.h"
#include "../neurons/neuronengine.h"

SodiumCurrent::SodiumCurrent(QQuickItem *parent)
{

}

double SodiumCurrent::sodiumActivation() const
{
    return m_sodiumActivation;
}

double SodiumCurrent::sodiumInactivation() const
{
    return m_sodiumInactivation;
}

double SodiumCurrent::meanSodiumConductance() const
{
    return m_meanSodiumConductance;
}

double SodiumCurrent::sodiumPotential() const
{
    return m_sodiumPotential;
}

double SodiumCurrent::voltage() const
{
    return m_voltage;
}

double SodiumCurrent::area() const
{
    return m_area;
}

void SodiumCurrent::setSodiumActivation(double sodiumActivation)
{
    if (qFuzzyCompare(m_sodiumActivation, sodiumActivation))
        return;

    m_sodiumActivation = sodiumActivation;
    emit sodiumActivationChanged(m_sodiumActivation);
}

void SodiumCurrent::setSodiumInactivation(double sodiumInactivation)
{
    if (qFuzzyCompare(m_sodiumInactivation, sodiumInactivation))
        return;

    m_sodiumInactivation = sodiumInactivation;
    emit sodiumInactivationChanged(m_sodiumInactivation);
}

void SodiumCurrent::setMeanSodiumConductance(double meanSodiumConductance)
{
    if (qFuzzyCompare(m_meanSodiumConductance, meanSodiumConductance))
        return;

    m_meanSodiumConductance = meanSodiumConductance;
    emit meanSodiumConductanceChanged(m_meanSodiumConductance);
}

void SodiumCurrent::setSodiumPotential(double sodiumPotential)
{
    if (qFuzzyCompare(m_sodiumPotential, sodiumPotential))
        return;

    m_sodiumPotential = sodiumPotential;
    emit sodiumPotentialChanged(m_sodiumPotential);
}

void SodiumCurrent::setVoltage(double voltage)
{
    if (qFuzzyCompare(m_voltage, voltage))
        return;

    m_voltage = voltage;
    emit voltageChanged(m_voltage);
}

void SodiumCurrent::setArea(double area)
{
    if (qFuzzyCompare(m_area, area))
        return;

    m_area = area;
    emit areaChanged(m_area);
}

void SodiumCurrent::stepEvent(double dt, bool parentEnabled)
{
    // TODO remove this boilerplate so we don't have to implement it in every current
    Q_UNUSED(dt);
    if(!parentEnabled) {
        return;
    }

    double V = m_voltage * 1e3;

    double sodiumActivationAlpha = 0.1 * ((V + 40) / (1 - exp(-((V+40)/10))));
    double sodiumActivationBeta = 4 * exp(-(V + 65) / 18.0);
    double sodiumInactivationAlpha = 0.07 * exp(-(V + 65) / 20.0);
    double sodiumInactivationBeta = 1.0 / (exp(-(V + 35)/10) + 1.0);

    double m = m_sodiumActivation;
    double alpham = sodiumActivationAlpha;
    double betam = sodiumActivationBeta;
    double dm = dt * (alpham * (1 - m) - betam * m);
    double h = m_sodiumInactivation;
    double alphah = sodiumInactivationAlpha;
    double betah = sodiumInactivationBeta;
    double dh = dt * (alphah * (1 - h) - betah * h);

    m += 1e3 * dm; // TODO WARNING this unit is wrong, just fixed because of dt
    h += 1e3 * dh;

    m = fmax(0.0, fmin(1.0, m));
    h = fmax(0.0, fmin(1.0, h));

    double gNa = m_meanSodiumConductance;

    double ENa = m_sodiumPotential;

    double m3 = m*m*m;

    setCurrent(-gNa * m3 * h * (m_voltage - ENa)); // TODO check units

    m_sodiumActivation = m;
    m_sodiumInactivation = h;
}

void SodiumCurrent::resetPropertiesEvent()
{
    Current::resetPropertiesEvent();
    setMeanSodiumConductance(120e-3);
    setSodiumPotential(50e-3);
    setArea(1e-18);
}


void SodiumCurrent::resetDynamicsEvent()
{
    Current::resetDynamicsEvent();
    setSodiumActivation(0.05);
    setSodiumInactivation(0.6);
    setVoltage(0.0);
}
