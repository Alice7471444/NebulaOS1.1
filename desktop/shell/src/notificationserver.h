#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QDateTime>

class NotificationServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList notifications READ notifications NOTIFY notificationsChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)
    Q_PROPERTY(bool doNotDisturb READ doNotDisturb WRITE setDoNotDisturb NOTIFY doNotDisturbChanged)

public:
    explicit NotificationServer(QObject *parent = nullptr);

    QVariantList notifications() const;
    int unreadCount() const;
    bool doNotDisturb() const;
    void setDoNotDisturb(bool enabled);

    Q_INVOKABLE void sendNotification(const QString &appName, const QString &title,
                                       const QString &body, const QString &icon = "");
    Q_INVOKABLE void dismissNotification(int id);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE void markAllRead();

signals:
    void notificationsChanged();
    void unreadCountChanged();
    void doNotDisturbChanged();
    void newNotification(const QVariantMap &notification);

private:
    QVariantList m_notifications;
    int m_nextId = 1;
    bool m_doNotDisturb = false;
};
