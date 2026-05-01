import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Application icon component for start menu and taskbar
Item {
    id: appIcon

    property string appId: ""
    property string appName: ""
    property string iconSource: ""
    property bool showLabel: true
    property int iconSize: 40

    signal clicked()

    width: showLabel ? 88 : iconSize + 12
    height: showLabel ? iconSize + 32 : iconSize + 12

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        // Icon
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: iconSize + 8
            height: iconSize + 8
            radius: root.radius
            color: mouseArea.containsMouse ?
                Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1) :
                "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Image {
                anchors.centerIn: parent
                width: iconSize
                height: iconSize
                source: iconSource ? "image://icon/" + iconSource : ""
                sourceSize: Qt.size(iconSize, iconSize)
                smooth: true

                // Fallback if icon not found
                Rectangle {
                    anchors.fill: parent
                    visible: parent.status === Image.Error
                    radius: 8
                    color: root.accentColor
                    Text {
                        anchors.centerIn: parent
                        text: appName.charAt(0).toUpperCase()
                        font.pixelSize: iconSize * 0.5
                        font.bold: true
                        color: "#ffffff"
                    }
                }
            }
        }

        // Label
        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: showLabel
            text: appName
            color: root.textColor
            font.pixelSize: 11
            font.family: "Inter"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            Layout.maximumWidth: 80
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: appIcon.clicked()
    }

    // Hover scale animation
    scale: mouseArea.containsMouse ? 1.05 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
}
