#include "windowmanager.h"

WindowManager::WindowManager(QObject *parent)
    : QObject(parent)
{
}

QVariantList WindowManager::openWindows() const { return m_openWindows; }
int WindowManager::activeWindowId() const { return m_activeWindowId; }

void WindowManager::activateWindow(int windowId) {
    if (m_activeWindowId != windowId) {
        m_activeWindowId = windowId;
        emit activeWindowChanged();
    }
}

void WindowManager::closeWindow(int windowId) {
    for (int i = 0; i < m_openWindows.size(); ++i) {
        if (m_openWindows[i].toMap()["id"].toInt() == windowId) {
            m_openWindows.removeAt(i);
            emit windowClosed(windowId);
            emit windowsChanged();
            break;
        }
    }
}

void WindowManager::minimizeWindow(int windowId) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["minimized"] = true;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}

void WindowManager::maximizeWindow(int windowId) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["maximized"] = true;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}

void WindowManager::restoreWindow(int windowId) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["minimized"] = false;
            map["maximized"] = false;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}

void WindowManager::snapWindow(int windowId, const QString &position) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["snapped"] = position;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}

QVariantList WindowManager::getSnapLayouts() const {
    return QVariantList{
        QVariantMap{{"name", "Left Half"}, {"icon", "snap-left"}, {"position", "left"}},
        QVariantMap{{"name", "Right Half"}, {"icon", "snap-right"}, {"position", "right"}},
        QVariantMap{{"name", "Top Left"}, {"icon", "snap-top-left"}, {"position", "top-left"}},
        QVariantMap{{"name", "Top Right"}, {"icon", "snap-top-right"}, {"position", "top-right"}},
        QVariantMap{{"name", "Bottom Left"}, {"icon", "snap-bottom-left"}, {"position", "bottom-left"}},
        QVariantMap{{"name", "Bottom Right"}, {"icon", "snap-bottom-right"}, {"position", "bottom-right"}},
        QVariantMap{{"name", "Maximize"}, {"icon", "snap-maximize"}, {"position", "maximized"}},
        QVariantMap{{"name", "Left Third"}, {"icon", "snap-left-third"}, {"position", "left-third"}},
        QVariantMap{{"name", "Center Third"}, {"icon", "snap-center-third"}, {"position", "center-third"}},
        QVariantMap{{"name", "Right Third"}, {"icon", "snap-right-third"}, {"position", "right-third"}},
    };
}

void WindowManager::moveWindow(int windowId, int x, int y) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["x"] = x;
            map["y"] = y;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}

void WindowManager::resizeWindow(int windowId, int width, int height) {
    for (auto &win : m_openWindows) {
        auto map = win.toMap();
        if (map["id"].toInt() == windowId) {
            map["width"] = width;
            map["height"] = height;
            win = map;
            emit windowsChanged();
            break;
        }
    }
}
