import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: lockScreen

    // Blurred wallpaper background
    Image {
        anchors.fill: parent
        source: settingsManager.value("desktop/wallpaper", "qrc:/images/default-wallpaper.jpg")
        fillMode: Image.PreserveAspectCrop
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
    }

    // Lock screen content
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // Clock
        Text {
            text: shellController.currentTime
            color: "#ffffff"
            font.pixelSize: 72
            font.bold: true
            font.family: "Inter"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: shellController.currentDate
            color: Qt.rgba(1, 1, 1, 0.7)
            font.pixelSize: 18
            font.family: "Inter"
            Layout.alignment: Qt.AlignHCenter
        }

        Item { height: 40 }

        // User avatar
        Rectangle {
            width: 80
            height: 80
            radius: 40
            color: root.accentColor
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.centerIn: parent
                text: "\u{1F464}"
                font.pixelSize: 36
            }
        }

        Text {
            text: "Nebula User"
            color: "#ffffff"
            font.pixelSize: 18
            font.family: "Inter"
            Layout.alignment: Qt.AlignHCenter
        }

        // Password field
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 280
            height: 44
            radius: 22
            color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.2)

            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 16
                color: "#ffffff"
                font.pixelSize: 14
                font.family: "Inter"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter

                Text {
                    anchors.fill: parent
                    visible: !passwordField.text
                    text: "Enter password"
                    color: Qt.rgba(1, 1, 1, 0.5)
                    font.pixelSize: 14
                    font.family: "Inter"
                    verticalAlignment: Text.AlignVCenter
                }

                onAccepted: {
                    // Validate password via PAM
                    lockScreenLoader.active = false
                }

                Keys.onEscapePressed: passwordField.text = ""
            }
        }

        NebulaButton {
            text: "Sign in"
            accent: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 140
            Layout.preferredHeight: 40
            onClicked: {
                lockScreenLoader.active = false
            }
        }
    }

    // Click to show password field (initially user drags up)
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: passwordField.forceActiveFocus()
    }
}
