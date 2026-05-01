#pragma once

#include <QObject>
#include <QString>

class PowerController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool charging READ charging NOTIFY chargingChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY hasBatteryChanged)

public:
    explicit PowerController(QObject *parent = nullptr);

    int batteryLevel() const;
    bool charging() const;
    bool hasBattery() const;

    Q_INVOKABLE void shutdown();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void hibernate();

signals:
    void batteryLevelChanged();
    void chargingChanged();
    void hasBatteryChanged();

private:
    void updateBatteryStatus();
    int m_batteryLevel = 100;
    bool m_charging = false;
    bool m_hasBattery = false;
};
