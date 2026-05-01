#include "powercontroller.h"

#include <QProcess>
#include <QFile>
#include <QTimer>

PowerController::PowerController(QObject *parent)
    : QObject(parent)
{
    updateBatteryStatus();

    auto *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &PowerController::updateBatteryStatus);
    timer->start(30000);
}

int PowerController::batteryLevel() const { return m_batteryLevel; }
bool PowerController::charging() const { return m_charging; }
bool PowerController::hasBattery() const { return m_hasBattery; }

void PowerController::shutdown() {
    QProcess::startDetached("systemctl", {"poweroff"});
}

void PowerController::restart() {
    QProcess::startDetached("systemctl", {"reboot"});
}

void PowerController::suspend() {
    QProcess::startDetached("systemctl", {"suspend"});
}

void PowerController::hibernate() {
    QProcess::startDetached("systemctl", {"hibernate"});
}

void PowerController::updateBatteryStatus() {
    QFile capacityFile("/sys/class/power_supply/BAT0/capacity");
    if (capacityFile.exists() && capacityFile.open(QIODevice::ReadOnly)) {
        m_hasBattery = true;
        m_batteryLevel = capacityFile.readAll().trimmed().toInt();
        capacityFile.close();

        QFile statusFile("/sys/class/power_supply/BAT0/status");
        if (statusFile.open(QIODevice::ReadOnly)) {
            m_charging = statusFile.readAll().trimmed() == "Charging";
            statusFile.close();
        }

        emit batteryLevelChanged();
        emit chargingChanged();
        emit hasBatteryChanged();
    } else {
        m_hasBattery = false;
        emit hasBatteryChanged();
    }
}
