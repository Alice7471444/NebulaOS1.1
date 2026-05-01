import QtQuick
import QtQuick.Effects

// Glassmorphism / Acrylic blur background component
Rectangle {
    id: glass

    property real blurAmount: root.blurRadius
    property real glassOpacity: root.glassOpacity

    color: Qt.rgba(
        root.surfaceColor.r,
        root.surfaceColor.g,
        root.surfaceColor.b,
        glassOpacity
    )
    radius: root.radius
    border.width: 1
    border.color: Qt.rgba(
        root.borderColor.r,
        root.borderColor.g,
        root.borderColor.b,
        0.3
    )

    // Subtle gradient overlay for glass effect
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.05) }
        }
    }

    // Entry animation
    Behavior on opacity {
        NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic }
    }
}
