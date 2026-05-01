import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: root
    visible: true
    visibility: Window.FullScreen
    title: "NebulaOS"
    color: "transparent"

    // Theme bindings
    readonly property color bgColor: themeEngine.backgroundColor
    readonly property color surfaceColor: themeEngine.surfaceColor
    readonly property color textColor: themeEngine.textColor
    readonly property color textSecondary: themeEngine.textSecondaryColor
    readonly property color accentColor: themeEngine.accentColor
    readonly property color borderColor: themeEngine.borderColor
    readonly property real blurRadius: themeEngine.blurRadius
    readonly property real glassOpacity: themeEngine.opacity
    readonly property int radius: themeEngine.cornerRadius
    readonly property int animDuration: themeEngine.animationDuration

    // Desktop background
    Image {
        id: wallpaper
        anchors.fill: parent
        source: settingsManager.value("desktop/wallpaper", "qrc:/images/default-wallpaper.jpg")
        fillMode: Image.PreserveAspectCrop
        smooth: true

        // Gradient overlay for depth
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.1) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) }
            }
        }
    }

    // Desktop area
    Loader {
        id: desktopLoader
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: taskbar.top
        }
        source: "panels/DesktopView.qml"
    }

    // Taskbar
    Taskbar {
        id: taskbar
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 52
    }

    // Start Menu overlay
    StartMenu {
        id: startMenu
        visible: shellController.startMenuVisible
        anchors.bottom: taskbar.top
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: 640
        height: 680
    }

    // Search Panel overlay
    SearchPanel {
        id: searchPanel
        visible: shellController.searchVisible
        anchors.bottom: taskbar.top
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: 640
        height: 500
    }

    // Notification Center
    NotificationCenter {
        id: notificationCenter
        visible: shellController.notificationCenterVisible
        anchors {
            right: parent.right
            bottom: taskbar.top
            bottomMargin: 8
            rightMargin: 12
        }
        width: 380
        height: parent.height * 0.7
    }

    // Quick Settings
    QuickSettings {
        id: quickSettings
        visible: shellController.quickSettingsVisible
        anchors {
            right: parent.right
            bottom: taskbar.top
            bottomMargin: 8
            rightMargin: 12
        }
        width: 360
        height: 420
    }

    // Widgets Panel
    WidgetsPanel {
        id: widgetsPanel
        visible: shellController.widgetsPanelVisible
        anchors {
            left: parent.left
            top: parent.top
            bottom: taskbar.top
            leftMargin: 12
            topMargin: 12
            bottomMargin: 8
        }
        width: 380
    }

    // Lock Screen
    Loader {
        id: lockScreenLoader
        anchors.fill: parent
        active: false
        source: "panels/LockScreen.qml"
        z: 1000
    }

    // Global keyboard shortcuts
    Shortcut {
        sequence: "Meta+S"
        onActivated: shellController.toggleStartMenu()
    }
    Shortcut {
        sequence: "Meta+Q"
        onActivated: shellController.toggleSearch()
    }
    Shortcut {
        sequence: "Meta+N"
        onActivated: shellController.toggleNotificationCenter()
    }
    Shortcut {
        sequence: "Meta+A"
        onActivated: shellController.toggleQuickSettings()
    }
    Shortcut {
        sequence: "Meta+W"
        onActivated: shellController.toggleWidgetsPanel()
    }
    Shortcut {
        sequence: "Meta+E"
        onActivated: shellController.openFileManager()
    }
    Shortcut {
        sequence: "Meta+T"
        onActivated: shellController.openTerminal()
    }
    Shortcut {
        sequence: "Meta+L"
        onActivated: shellController.lockScreen()
    }
    Shortcut {
        sequence: "Print"
        onActivated: shellController.takeScreenshot()
    }

    // Click outside to close overlays
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            shellController.startMenuVisible = false
            shellController.searchVisible = false
            shellController.notificationCenterVisible = false
            shellController.quickSettingsVisible = false
        }
    }
}
