import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GlassBackground {
    id: quickSettings

    opacity: visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Quick toggle grid
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 8
            columnSpacing: 8

            QuickToggle { label: "Wi-Fi"; icon: "\u{1F4F6}"; active: true }
            QuickToggle { label: "Bluetooth"; icon: "\u{1F399}" }
            QuickToggle { label: "Airplane"; icon: "\u2708" }
            QuickToggle { label: "Dark Mode"; icon: "\u{1F319}"; active: themeEngine.darkMode
                onClicked: themeEngine.darkMode = !themeEngine.darkMode
            }
            QuickToggle { label: "Do Not Disturb"; icon: "\u{1F515}"
                active: notificationServer.doNotDisturb
                onClicked: notificationServer.doNotDisturb = !notificationServer.doNotDisturb
            }
            QuickToggle { label: "Night Light"; icon: "\u{1F506}" }
            QuickToggle { label: "VPN"; icon: "\u{1F512}" }
            QuickToggle { label: "Hotspot"; icon: "\u{1F4E1}" }
            QuickToggle { label: "Cast"; icon: "\u{1F4FA}" }
        }

        // Brightness slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Text { text: "\u2600"; font.pixelSize: 14; color: root.textSecondary }
                Text { text: "Brightness"; color: root.textSecondary; font.pixelSize: 12; font.family: "Inter" }
            }
            Slider {
                Layout.fillWidth: true
                from: 0; to: 100; value: 80
                Material.accent: root.accentColor
            }
        }

        // Volume slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Text { text: "\u{1F50A}"; font.pixelSize: 14; color: root.textSecondary }
                Text { text: "Volume"; color: root.textSecondary; font.pixelSize: 12; font.family: "Inter" }
            }
            Slider {
                Layout.fillWidth: true
                from: 0; to: 100; value: 70
                Material.accent: root.accentColor
            }
        }

        Item { Layout.fillHeight: true }

        // Bottom row: Battery + Settings
        RowLayout {
            Layout.fillWidth: true

            Column {
                visible: powerController.hasBattery
                spacing: 2
                Text {
                    text: powerController.batteryLevel + "%"
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "Inter"
                }
                Text {
                    text: powerController.charging ? "Charging" : "On battery"
                    color: root.textSecondary
                    font.pixelSize: 11
                    font.family: "Inter"
                }
            }

            Item { Layout.fillWidth: true }

            NebulaButton {
                text: "\u2699 Settings"
                onClicked: {
                    shellController.openSettings()
                    shellController.quickSettingsVisible = false
                }
            }
        }
    }

    // Quick toggle button component
    component QuickToggle: Rectangle {
        property string label: ""
        property string icon: ""
        property bool active: false

        signal clicked()

        Layout.fillWidth: true
        height: 60
        radius: 10
        color: active ?
            Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2) :
            Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06)
        border.width: active ? 1 : 0
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)

        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: icon
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
                color: active ? root.accentColor : root.textColor
            }
            Text {
                text: label
                font.pixelSize: 10
                font.family: "Inter"
                anchors.horizontalCenter: parent.horizontalCenter
                color: active ? root.accentColor : root.textSecondary
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
