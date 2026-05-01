import QtQuick
import QtQuick.Controls

Button {
    id: btn

    property bool accent: false
    property real btnRadius: 8

    contentItem: Text {
        text: btn.text
        color: accent ? "#ffffff" : root.textColor
        font.pixelSize: 13
        font.family: "Inter"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: btnRadius
        color: {
            if (btn.pressed) return accent ? Qt.darker(root.accentColor, 1.2) : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15)
            if (btn.hovered) return accent ? Qt.lighter(root.accentColor, 1.1) : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
            return accent ? root.accentColor : "transparent"
        }
        border.width: accent ? 0 : 1
        border.color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.3)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
