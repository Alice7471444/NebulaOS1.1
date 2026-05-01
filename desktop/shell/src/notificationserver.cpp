#include "notificationserver.h"

NotificationServer::NotificationServer(QObject *parent)
    : QObject(parent)
{
}

QVariantList NotificationServer::notifications() const { return m_notifications; }

int NotificationServer::unreadCount() const {
    int count = 0;
    for (const auto &n : m_notifications) {
        if (!n.toMap()["read"].toBool()) count++;
    }
    return count;
}

bool NotificationServer::doNotDisturb() const { return m_doNotDisturb; }
void NotificationServer::setDoNotDisturb(bool enabled) {
    if (m_doNotDisturb != enabled) {
        m_doNotDisturb = enabled;
        emit doNotDisturbChanged();
    }
}

void NotificationServer::sendNotification(const QString &appName, const QString &title,
                                            const QString &body, const QString &icon) {
    QVariantMap notification;
    notification["id"] = m_nextId++;
    notification["appName"] = appName;
    notification["title"] = title;
    notification["body"] = body;
    notification["icon"] = icon;
    notification["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    notification["read"] = false;

    m_notifications.prepend(notification);
    emit notificationsChanged();
    emit unreadCountChanged();

    if (!m_doNotDisturb) {
        emit newNotification(notification);
    }
}

void NotificationServer::dismissNotification(int id) {
    for (int i = 0; i < m_notifications.size(); ++i) {
        if (m_notifications[i].toMap()["id"].toInt() == id) {
            m_notifications.removeAt(i);
            emit notificationsChanged();
            emit unreadCountChanged();
            break;
        }
    }
}

void NotificationServer::clearAll() {
    m_notifications.clear();
    emit notificationsChanged();
    emit unreadCountChanged();
}

void NotificationServer::markAllRead() {
    for (auto &n : m_notifications) {
        auto map = n.toMap();
        map["read"] = true;
        n = map;
    }
    emit unreadCountChanged();
}
