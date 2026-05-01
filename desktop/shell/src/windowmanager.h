#pragma once

#include <QObject>
#include <QVariantList>
#include <QRect>
#include <QVariantMap>

class WindowManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList openWindows READ openWindows NOTIFY windowsChanged)
    Q_PROPERTY(int activeWindowId READ activeWindowId NOTIFY activeWindowChanged)

public:
    explicit WindowManager(QObject *parent = nullptr);

    QVariantList openWindows() const;
    int activeWindowId() const;

    Q_INVOKABLE void activateWindow(int windowId);
    Q_INVOKABLE void closeWindow(int windowId);
    Q_INVOKABLE void minimizeWindow(int windowId);
    Q_INVOKABLE void maximizeWindow(int windowId);
    Q_INVOKABLE void restoreWindow(int windowId);
    Q_INVOKABLE void snapWindow(int windowId, const QString &position);
    Q_INVOKABLE QVariantList getSnapLayouts() const;
    Q_INVOKABLE void moveWindow(int windowId, int x, int y);
    Q_INVOKABLE void resizeWindow(int windowId, int width, int height);

signals:
    void windowsChanged();
    void activeWindowChanged();
    void windowOpened(int windowId);
    void windowClosed(int windowId);

private:
    QVariantList m_openWindows;
    int m_activeWindowId = -1;
};
