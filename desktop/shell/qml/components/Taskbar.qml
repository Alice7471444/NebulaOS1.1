import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Windows 11 inspired centered taskbar
Item {
    id: taskbar

    GlassBackground {
        anchors.fill: parent
        anchors.margins: 4
        radius: 14

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2

            // Left section: Widgets button
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    spacing: 4

                    // Widgets button
                    TaskbarButton {
                        icon: "widgets"
                        tooltip: "Widgets"
                        onClicked: shellController.toggleWidgetsPanel()
                    }
                }
            }

            // Center section: Pinned apps
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                // Start button
                TaskbarButton {
                    icon: "nebula-logo"
                    tooltip: "Start"
                    isStart: true
                    onClicked: shellController.toggleStartMenu()
                }

                // Search button
                TaskbarButton {
                    icon: "search"
                    tooltip: "Search"
                    onClicked: shellController.toggleSearch()
                }

                // Separator
                Rectangle {
                    width: 1
                    height: 24
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15)
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Pinned app icons
                Repeater {
                    model: shellController.pinnedApps
                    delegate: TaskbarButton {
                        icon: modelData.icon || ""
                        tooltip: modelData.name || ""
                        onClicked: shellController.launchApp(modelData.id)
                    }
                }
            }

            // Right section: System tray
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    spacing: 4

                    // System tray icons
                    TaskbarButton {
                        icon: "network-wireless"
                        tooltip: "Network"
                        small: true
                    }

                    TaskbarButton {
                        icon: "audio-volume-high"
                        tooltip: "Volume"
                        small: true
                    }

                    TaskbarButton {
                        icon: powerController.hasBattery ? "battery" : ""
                        tooltip: powerController.hasBattery ? "Battery: " + powerController.batteryLevel + "%" : ""
                        visible: powerController.hasBattery
                        small: true
                    }

                    // Quick Settings button
                    Rectangle {
                        width: quickSettingsRow.width + 16
                        height: 36
                        radius: 8
                        color: quickSettingsMouse.containsMouse ?
                            Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08) :
                            "transparent"

                        Row {
                            id: quickSettingsRow
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "\u{1F50A}"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "\u{1F4F6}"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: quickSettingsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: shellController.toggleQuickSettings()
                        }
                    }

                    // Clock & Notification button
                    Rectangle {
                        width: clockColumn.width + 16
                        height: 36
                        radius: 8
                        color: clockMouse.containsMouse ?
                            Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08) :
                            "transparent"

                        Column {
                            id: clockColumn
                            anchors.centerIn: parent
                            spacing: -2

                            Text {
                                text: shellController.currentTime
                                color: root.textColor
                                font.pixelSize: 12
                                font.family: "Inter"
                                horizontalAlignment: Text.AlignRight
                                anchors.right: parent.right
                            }
                            Text {
                                text: shellController.currentDate
                                color: root.textSecondary
                                font.pixelSize: 10
                                font.family: "Inter"
                                horizontalAlignment: Text.AlignRight
                                anchors.right: parent.right
                            }
                        }

                        // Notification badge
                        Rectangle {
                            visible: notificationServer.unreadCount > 0
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 2
                            width: 16
                            height: 16
                            radius: 8
                            color: root.accentColor
                            Text {
                                anchors.centerIn: parent
                                text: notificationServer.unreadCount
                                color: "#ffffff"
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: clockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: shellController.toggleNotificationCenter()
                        }
                    }

                    // Show desktop button
                    Rectangle {
                        width: 6
                        height: 36
                        radius: 3
                        color: showDesktopMouse.containsMouse ?
                            Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.5) :
                            Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1)

                        MouseArea {
                            id: showDesktopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Toggle show desktop
                            }
                        }
                    }
                }
            }
        }
    }

    // Taskbar button component
    component TaskbarButton: Rectangle {
        property string icon: ""
        property string tooltip: ""
        property bool isStart: false
        property bool small: false
        property bool active: false

        signal clicked()

        width: small ? 32 : 44
        height: 44
        radius: 8
        color: {
            if (btnMouse.pressed) return Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15)
            if (btnMouse.containsMouse) return Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
            return "transparent"
        }

        Behavior on color { ColorAnimation { duration: 150 } }

        // Icon placeholder
        Text {
            anchors.centerIn: parent
            text: {
                if (isStart) return "\u2726"  // Star symbol for start
                if (icon === "search") return "\u{1F50D}"
                if (icon === "widgets") return "\u{2B1C}"
                return icon.charAt(0).toUpperCase()
            }
            font.pixelSize: isStart ? 20 : (small ? 14 : 16)
            color: isStart ? root.accentColor : root.textColor
        }

        // Active indicator
        Rectangle {
            visible: active
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 2
            width: 16
            height: 3
            radius: 1.5
            color: root.accentColor
        }

        ToolTip {
            visible: btnMouse.containsMouse && tooltip !== ""
            text: tooltip
            delay: 800
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
