import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Windows 11 inspired Start Menu with glassmorphism
GlassBackground {
    id: startMenu

    // Entry animation
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.95
    transformOrigin: Item.Bottom

    Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Search bar
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 20
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06)
            border.width: 1
            border.color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.3)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 8

                Text {
                    text: "\u{1F50D}"
                    font.pixelSize: 14
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: root.textColor
                    font.pixelSize: 13
                    font.family: "Inter"
                    clip: true

                    Text {
                        anchors.fill: parent
                        visible: !searchInput.text
                        text: "Search apps, settings, and files"
                        color: root.textSecondary
                        font.pixelSize: 13
                        font.family: "Inter"
                        verticalAlignment: Text.AlignVCenter
                    }

                    onTextChanged: {
                        if (text.length > 0) {
                            searchProvider.search(text)
                        } else {
                            searchProvider.clearResults()
                        }
                    }
                }
            }
        }

        // Pinned section
        Text {
            text: "Pinned"
            color: root.textColor
            font.pixelSize: 14
            font.bold: true
            font.family: "Inter"
        }

        // Pinned apps grid
        GridLayout {
            Layout.fillWidth: true
            columns: 6
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: shellController.pinnedApps
                delegate: AppIcon {
                    appId: modelData.id
                    appName: modelData.name
                    iconSource: modelData.icon
                    iconSize: 36
                    onClicked: {
                        shellController.launchApp(modelData.id)
                        shellController.startMenuVisible = false
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.3)
        }

        // Recommended / Recent section
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Recommended"
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
                font.family: "Inter"
            }
            Item { Layout.fillWidth: true }
            NebulaButton {
                text: "More >"
                onClicked: { /* Navigate to all apps */ }
            }
        }

        // Recent apps list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: shellController.recentApps

            delegate: Rectangle {
                width: ListView.view.width
                height: 48
                radius: 8
                color: recentMouse.containsMouse ?
                    Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06) :
                    "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: root.accentColor
                        Text {
                            anchors.centerIn: parent
                            text: (modelData.name || "?").charAt(0)
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name || ""
                            color: root.textColor
                            font.pixelSize: 13
                            font.family: "Inter"
                        }
                        Text {
                            text: modelData.time || "Recently opened"
                            color: root.textSecondary
                            font.pixelSize: 11
                            font.family: "Inter"
                        }
                    }
                }

                MouseArea {
                    id: recentMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shellController.launchApp(modelData.id)
                }
            }
        }

        // Bottom bar: User & Power
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // User profile
            Rectangle {
                width: userRow.width + 16
                height: 44
                radius: 8
                color: userMouse.containsMouse ?
                    Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06) : "transparent"

                Row {
                    id: userRow
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: root.accentColor
                        Text {
                            anchors.centerIn: parent
                            text: "\u{1F464}"
                            font.pixelSize: 14
                        }
                    }
                    Text {
                        text: "Nebula User"
                        color: root.textColor
                        font.pixelSize: 13
                        font.family: "Inter"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: userMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shellController.openSettings("users")
                }
            }

            Item { Layout.fillWidth: true }

            // Power button
            Rectangle {
                width: 44
                height: 44
                radius: 8
                color: powerMouse.containsMouse ?
                    Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\u23FB"  // Power symbol
                    font.pixelSize: 18
                    color: root.textColor
                }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: powerMenu.open()
                }

                Menu {
                    id: powerMenu
                    y: -implicitHeight

                    MenuItem {
                        text: "Sleep"
                        onTriggered: powerController.suspend()
                    }
                    MenuItem {
                        text: "Restart"
                        onTriggered: shellController.restart()
                    }
                    MenuItem {
                        text: "Shut down"
                        onTriggered: shellController.shutdown()
                    }
                }
            }
        }
    }
}
