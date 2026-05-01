import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GlassBackground {
    id: widgetsPanel

    opacity: visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Widgets"
            color: root.textColor
            font.pixelSize: 18
            font.bold: true
            font.family: "Inter"
        }

        // Weather widget
        Rectangle {
            Layout.fillWidth: true
            height: 120
            radius: 12
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1a2a4a" }
                GradientStop { position: 1.0; color: "#2a3a5a" }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16

                Column {
                    spacing: 4
                    Text {
                        text: "22\u00B0C"
                        color: "#ffffff"
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "Inter"
                    }
                    Text {
                        text: "Partly Cloudy"
                        color: Qt.rgba(1, 1, 1, 0.7)
                        font.pixelSize: 13
                        font.family: "Inter"
                    }
                    Text {
                        text: "Your Location"
                        color: Qt.rgba(1, 1, 1, 0.5)
                        font.pixelSize: 11
                        font.family: "Inter"
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "\u26C5"
                    font.pixelSize: 48
                }
            }
        }

        // Calendar widget
        Rectangle {
            Layout.fillWidth: true
            height: 100
            radius: 12
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.04)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    text: "\u{1F4C5} Calendar"
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "Inter"
                }

                Text {
                    text: shellController.currentDate
                    color: root.textSecondary
                    font.pixelSize: 13
                    font.family: "Inter"
                }

                Text {
                    text: "No upcoming events"
                    color: root.textSecondary
                    font.pixelSize: 12
                    font.family: "Inter"
                    font.italic: true
                }
            }
        }

        // System Monitor widget
        Rectangle {
            Layout.fillWidth: true
            height: 140
            radius: 12
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.04)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    text: "\u{1F4CA} System"
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "Inter"
                }

                // CPU bar
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "CPU"; color: root.textSecondary; font.pixelSize: 11; font.family: "Inter" }
                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1)
                        Rectangle {
                            width: parent.width * 0.35
                            height: parent.height
                            radius: 3
                            color: root.accentColor
                        }
                    }
                }

                // RAM bar
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Memory"; color: root.textSecondary; font.pixelSize: 11; font.family: "Inter" }
                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1)
                        Rectangle {
                            width: parent.width * 0.55
                            height: parent.height
                            radius: 3
                            color: "#44bb88"
                        }
                    }
                }
            }
        }

        // AI Assistant quick access
        Rectangle {
            Layout.fillWidth: true
            height: 70
            radius: 12
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15) }
                GradientStop { position: 1.0; color: Qt.rgba(0.5, 0.3, 0.8, 0.15) }
            }
            border.width: 1
            border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16

                Column {
                    spacing: 4
                    Text {
                        text: "\u2728 Nebula AI"
                        color: root.textColor
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "Inter"
                    }
                    Text {
                        text: "Ask me anything..."
                        color: root.textSecondary
                        font.pixelSize: 12
                        font.family: "Inter"
                    }
                }

                Item { Layout.fillWidth: true }

                NebulaButton {
                    text: "Open"
                    accent: true
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
            }
        }

        Item { Layout.fillHeight: true }
    }
}
