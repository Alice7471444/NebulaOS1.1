#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QDateTime>

class SettingsManager;
class ThemeEngine;
class WindowManager;
class NotificationServer;
class SearchProvider;
class VirtualDesktopManager;
class PowerController;

class ShellController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool startMenuVisible READ startMenuVisible WRITE setStartMenuVisible NOTIFY startMenuVisibleChanged)
    Q_PROPERTY(bool searchVisible READ searchVisible WRITE setSearchVisible NOTIFY searchVisibleChanged)
    Q_PROPERTY(bool notificationCenterVisible READ notificationCenterVisible WRITE setNotificationCenterVisible NOTIFY notificationCenterVisibleChanged)
    Q_PROPERTY(bool quickSettingsVisible READ quickSettingsVisible WRITE setQuickSettingsVisible NOTIFY quickSettingsVisibleChanged)
    Q_PROPERTY(bool widgetsPanelVisible READ widgetsPanelVisible WRITE setWidgetsPanelVisible NOTIFY widgetsPanelVisibleChanged)
    Q_PROPERTY(QString currentTime READ currentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QString currentDate READ currentDate NOTIFY currentDateChanged)
    Q_PROPERTY(QVariantList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
    Q_PROPERTY(QVariantList recentApps READ recentApps NOTIFY recentAppsChanged)
    Q_PROPERTY(QVariantList allApps READ allApps NOTIFY allAppsChanged)

public:
    explicit ShellController(
        SettingsManager *settings, ThemeEngine *theme,
        WindowManager *windowMgr, NotificationServer *notifServer,
        SearchProvider *search, VirtualDesktopManager *vdMgr,
        PowerController *power, QObject *parent = nullptr
    );

    bool startMenuVisible() const;
    void setStartMenuVisible(bool visible);

    bool searchVisible() const;
    void setSearchVisible(bool visible);

    bool notificationCenterVisible() const;
    void setNotificationCenterVisible(bool visible);

    bool quickSettingsVisible() const;
    void setQuickSettingsVisible(bool visible);

    bool widgetsPanelVisible() const;
    void setWidgetsPanelVisible(bool visible);

    QString currentTime() const;
    QString currentDate() const;

    QVariantList pinnedApps() const;
    QVariantList recentApps() const;
    QVariantList allApps() const;

    Q_INVOKABLE void launchApp(const QString &appId);
    Q_INVOKABLE void toggleStartMenu();
    Q_INVOKABLE void toggleSearch();
    Q_INVOKABLE void toggleNotificationCenter();
    Q_INVOKABLE void toggleQuickSettings();
    Q_INVOKABLE void toggleWidgetsPanel();
    Q_INVOKABLE void lockScreen();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void shutdown();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void openSettings(const QString &page = "");
    Q_INVOKABLE void openFileManager(const QString &path = "");
    Q_INVOKABLE void openTerminal();
    Q_INVOKABLE void openBrowser(const QString &url = "");
    Q_INVOKABLE void takeScreenshot();

signals:
    void startMenuVisibleChanged();
    void searchVisibleChanged();
    void notificationCenterVisibleChanged();
    void quickSettingsVisibleChanged();
    void widgetsPanelVisibleChanged();
    void currentTimeChanged();
    void currentDateChanged();
    void pinnedAppsChanged();
    void recentAppsChanged();
    void allAppsChanged();

private:
    void initializePinnedApps();
    void scanInstalledApps();
    void updateClock();

    SettingsManager *m_settings;
    ThemeEngine *m_theme;
    WindowManager *m_windowManager;
    NotificationServer *m_notificationServer;
    SearchProvider *m_searchProvider;
    VirtualDesktopManager *m_virtualDesktopManager;
    PowerController *m_powerController;

    bool m_startMenuVisible = false;
    bool m_searchVisible = false;
    bool m_notificationCenterVisible = false;
    bool m_quickSettingsVisible = false;
    bool m_widgetsPanelVisible = false;

    QVariantList m_pinnedApps;
    QVariantList m_recentApps;
    QVariantList m_allApps;
};
