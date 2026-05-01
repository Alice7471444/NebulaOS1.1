#include "shellcontroller.h"
#include "settingsmanager.h"
#include "themeengine.h"
#include "windowmanager.h"
#include "notificationserver.h"
#include "searchprovider.h"
#include "virtualdesktopmanager.h"
#include "powercontroller.h"

#include <QProcess>
#include <QTimer>
#include <QDir>
#include <QStandardPaths>
#include <QVariantMap>

ShellController::ShellController(
    SettingsManager *settings, ThemeEngine *theme,
    WindowManager *windowMgr, NotificationServer *notifServer,
    SearchProvider *search, VirtualDesktopManager *vdMgr,
    PowerController *power, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
    , m_theme(theme)
    , m_windowManager(windowMgr)
    , m_notificationServer(notifServer)
    , m_searchProvider(search)
    , m_virtualDesktopManager(vdMgr)
    , m_powerController(power)
{
    initializePinnedApps();
    scanInstalledApps();

    auto *clockTimer = new QTimer(this);
    connect(clockTimer, &QTimer::timeout, this, &ShellController::updateClock);
    clockTimer->start(1000);
    updateClock();
}

bool ShellController::startMenuVisible() const { return m_startMenuVisible; }
void ShellController::setStartMenuVisible(bool visible) {
    if (m_startMenuVisible != visible) {
        m_startMenuVisible = visible;
        if (visible) {
            setSearchVisible(false);
            setNotificationCenterVisible(false);
            setQuickSettingsVisible(false);
        }
        emit startMenuVisibleChanged();
    }
}

bool ShellController::searchVisible() const { return m_searchVisible; }
void ShellController::setSearchVisible(bool visible) {
    if (m_searchVisible != visible) {
        m_searchVisible = visible;
        if (visible) setStartMenuVisible(false);
        emit searchVisibleChanged();
    }
}

bool ShellController::notificationCenterVisible() const { return m_notificationCenterVisible; }
void ShellController::setNotificationCenterVisible(bool visible) {
    if (m_notificationCenterVisible != visible) {
        m_notificationCenterVisible = visible;
        emit notificationCenterVisibleChanged();
    }
}

bool ShellController::quickSettingsVisible() const { return m_quickSettingsVisible; }
void ShellController::setQuickSettingsVisible(bool visible) {
    if (m_quickSettingsVisible != visible) {
        m_quickSettingsVisible = visible;
        emit quickSettingsVisibleChanged();
    }
}

bool ShellController::widgetsPanelVisible() const { return m_widgetsPanelVisible; }
void ShellController::setWidgetsPanelVisible(bool visible) {
    if (m_widgetsPanelVisible != visible) {
        m_widgetsPanelVisible = visible;
        emit widgetsPanelVisibleChanged();
    }
}

QString ShellController::currentTime() const {
    return QDateTime::currentDateTime().toString("hh:mm");
}

QString ShellController::currentDate() const {
    return QDateTime::currentDateTime().toString("dddd, MMMM d");
}

QVariantList ShellController::pinnedApps() const { return m_pinnedApps; }
QVariantList ShellController::recentApps() const { return m_recentApps; }
QVariantList ShellController::allApps() const { return m_allApps; }

void ShellController::initializePinnedApps() {
    m_pinnedApps = {
        QVariantMap{{"id", "firefox"}, {"name", "Firefox"}, {"icon", "firefox"}, {"exec", "firefox"}},
        QVariantMap{{"id", "thunar"}, {"name", "Files"}, {"icon", "system-file-manager"}, {"exec", "thunar"}},
        QVariantMap{{"id", "terminal"}, {"name", "Terminal"}, {"icon", "utilities-terminal"}, {"exec", "alacritty"}},
        QVariantMap{{"id", "settings"}, {"name", "Settings"}, {"icon", "preferences-system"}, {"exec", "nebula-settings"}},
        QVariantMap{{"id", "appstore"}, {"name", "App Store"}, {"icon", "system-software-install"}, {"exec", "gnome-software"}},
        QVariantMap{{"id", "calculator"}, {"name", "Calculator"}, {"icon", "accessories-calculator"}, {"exec", "gnome-calculator"}},
    };
    emit pinnedAppsChanged();
}

void ShellController::scanInstalledApps() {
    m_allApps.clear();
    QStringList appDirs = {
        "/usr/share/applications",
        QDir::homePath() + "/.local/share/applications"
    };

    for (const auto &dir : appDirs) {
        QDir appDir(dir);
        if (!appDir.exists()) continue;
        for (const auto &entry : appDir.entryInfoList({"*.desktop"}, QDir::Files)) {
            QVariantMap app;
            app["id"] = entry.baseName();
            app["name"] = entry.baseName();
            app["path"] = entry.absoluteFilePath();
            m_allApps.append(app);
        }
    }
    emit allAppsChanged();
}

void ShellController::launchApp(const QString &appId) {
    for (const auto &app : m_pinnedApps) {
        auto map = app.toMap();
        if (map["id"].toString() == appId) {
            QProcess::startDetached(map["exec"].toString(), {});
            return;
        }
    }
    QProcess::startDetached(appId, {});
}

void ShellController::toggleStartMenu() { setStartMenuVisible(!m_startMenuVisible); }
void ShellController::toggleSearch() { setSearchVisible(!m_searchVisible); }
void ShellController::toggleNotificationCenter() { setNotificationCenterVisible(!m_notificationCenterVisible); }
void ShellController::toggleQuickSettings() { setQuickSettingsVisible(!m_quickSettingsVisible); }
void ShellController::toggleWidgetsPanel() { setWidgetsPanelVisible(!m_widgetsPanelVisible); }

void ShellController::lockScreen() {
    QProcess::startDetached("loginctl", {"lock-session"});
}

void ShellController::logout() {
    QProcess::startDetached("loginctl", {"terminate-session", ""});
}

void ShellController::shutdown() {
    m_powerController->shutdown();
}

void ShellController::restart() {
    m_powerController->restart();
}

void ShellController::openSettings(const QString &page) {
    QStringList args;
    if (!page.isEmpty()) args << "--page" << page;
    QProcess::startDetached("nebula-settings", args);
}

void ShellController::openFileManager(const QString &path) {
    QStringList args;
    if (!path.isEmpty()) args << path;
    QProcess::startDetached("thunar", args);
}

void ShellController::openTerminal() {
    QProcess::startDetached("alacritty", {});
}

void ShellController::openBrowser(const QString &url) {
    QStringList args;
    if (!url.isEmpty()) args << url;
    QProcess::startDetached("firefox", args);
}

void ShellController::takeScreenshot() {
    QProcess::startDetached("gnome-screenshot", {"-i"});
}

void ShellController::updateClock() {
    emit currentTimeChanged();
    emit currentDateChanged();
}
