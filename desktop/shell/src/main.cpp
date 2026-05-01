/**
 * NebulaOS Desktop Shell
 * Main entry point for the desktop environment
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QFontDatabase>
#include <QDir>

#include "shellcontroller.h"
#include "windowmanager.h"
#include "notificationserver.h"
#include "settingsmanager.h"
#include "themeengine.h"
#include "searchprovider.h"
#include "virtualdesktopmanager.h"
#include "powercontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("NebulaOS Shell");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("NebulaOS");
    app.setDesktopFileName("nebula-shell");

    // Set the visual style
    QQuickStyle::setStyle("Material");

    // Load custom fonts
    QFontDatabase::addApplicationFont(":/fonts/Inter-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Inter-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/FiraCode-Regular.ttf");

    // Initialize core managers
    SettingsManager settingsManager;
    ThemeEngine themeEngine(&settingsManager);
    WindowManager windowManager;
    NotificationServer notificationServer;
    SearchProvider searchProvider;
    VirtualDesktopManager virtualDesktopManager;
    PowerController powerController;
    ShellController shellController(
        &settingsManager, &themeEngine, &windowManager,
        &notificationServer, &searchProvider, &virtualDesktopManager,
        &powerController
    );

    // Setup QML engine
    QQmlApplicationEngine engine;

    // Expose C++ objects to QML
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("shellController", &shellController);
    context->setContextProperty("windowManager", &windowManager);
    context->setContextProperty("notificationServer", &notificationServer);
    context->setContextProperty("settingsManager", &settingsManager);
    context->setContextProperty("themeEngine", &themeEngine);
    context->setContextProperty("searchProvider", &searchProvider);
    context->setContextProperty("virtualDesktopManager", &virtualDesktopManager);
    context->setContextProperty("powerController", &powerController);

    // Load the main QML shell
    const QUrl mainQml(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [mainQml](QObject *obj, const QUrl &objUrl) {
        if (!obj && mainQml == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(mainQml);

    return app.exec();
}
