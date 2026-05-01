import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GlassBackground {
    id: notifCenter

    opacity: visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Notifications"
                color: root.textColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Inter"
            }
            Item { Layout.fillWidth: true }

            NebulaButton {
                text: "Clear all"
                onClicked: notificationServer.clearAll()
            }
        }

        // Do Not Disturb toggle
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 10
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.04)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                Text {
                    text: "Do Not Disturb"
                    color: root.textColor
                    font.pixelSize: 13
                    font.family: "Inter"
                }
                Item { Layout.fillWidth: true }
                Switch {
                    checked: notificationServer.doNotDisturb
                    onCheckedChanged: notificationServer.doNotDisturb = checked
                }
            }
        }

        // Notification list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: notificationServer.notifications

            delegate: Rectangle {
                width: ListView.view.width
                height: notifContent.height + 24
                radius: 10
                color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.04)
                border.width: 1
                border.color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.2)

                ColumnLayout {
                    id: notifContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 12
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.appName || ""
                            color: root.accentColor
                            font.pixelSize: 11
                            font.family: "Inter"
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: {
                                var ts = modelData.timestamp || ""
                                return ts ? new Date(ts).toLocaleTimeString(Qt.locale(), "hh:mm") : ""
                            }
                            color: root.textSecondary
                            font.pixelSize: 10
                            font.family: "Inter"
                        }
                        // Dismiss button
                        Text {
                            text: "\u2715"
                            color: root.textSecondary
                            font.pixelSize: 12
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notificationServer.dismissNotification(modelData.id)
                            }
                        }
                    }

                    Text {
                        text: modelData.title || ""
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "Inter"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: modelData.body || ""
                        color: root.textSecondary
                        font.pixelSize: 12
                        font.family: "Inter"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                visible: notificationServer.notifications.length === 0
                spacing: 8
                Text {
                    text: "\u{1F514}"
                    font.pixelSize: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "No notifications"
                    color: root.textSecondary
                    font.pixelSize: 14
                    font.family: "Inter"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Calendar mini widget
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 10
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.04)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12

                Column {
                    spacing: 2
                    Text {
                        text: shellController.currentTime
                        color: root.textColor
                        font.pixelSize: 20
                        font.bold: true
                        font.family: "Inter"
                    }
                    Text {
                        text: shellController.currentDate
                        color: root.textSecondary
                        font.pixelSize: 12
                        font.family: "Inter"
                    }
                }
            }
        }
    }
}
