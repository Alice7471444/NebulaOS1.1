import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: desktopView

    // Right-click context menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: desktopContextMenu.popup()
    }

    Menu {
        id: desktopContextMenu

        MenuItem {
            text: "View"
            Menu {
                MenuItem { text: "Large icons" }
                MenuItem { text: "Medium icons" }
                MenuItem { text: "Small icons" }
                MenuSeparator {}
                MenuItem { text: "Auto arrange icons" }
                MenuItem { text: "Align icons to grid" }
            }
        }
        MenuItem {
            text: "Sort by"
            Menu {
                MenuItem { text: "Name" }
                MenuItem { text: "Size" }
                MenuItem { text: "Date modified" }
                MenuItem { text: "Type" }
            }
        }
        MenuSeparator {}
        MenuItem {
            text: "Refresh"
            onTriggered: { /* Refresh desktop */ }
        }
        MenuSeparator {}
        MenuItem {
            text: "New folder"
            onTriggered: { /* Create new folder */ }
        }
        MenuItem {
            text: "New file"
            onTriggered: { /* Create new file */ }
        }
        MenuSeparator {}
        MenuItem {
            text: "Display settings"
            onTriggered: shellController.openSettings("display")
        }
        MenuItem {
            text: "Personalize"
            onTriggered: shellController.openSettings("themes")
        }
        MenuItem {
            text: "Open terminal here"
            onTriggered: shellController.openTerminal()
        }
    }

    // Virtual desktop indicator
    Rectangle {
        visible: virtualDesktopManager.desktopCount > 1
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 12
        width: vdRow.width + 20
        height: 36
        radius: 18
        color: Qt.rgba(root.surfaceColor.r, root.surfaceColor.g, root.surfaceColor.b, 0.7)
        border.width: 1
        border.color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.3)

        Row {
            id: vdRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: virtualDesktopManager.desktops
                delegate: Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: index === virtualDesktopManager.currentDesktop ?
                        root.accentColor : root.textSecondary

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: virtualDesktopManager.setCurrentDesktop(index)
                    }
                }
            }
        }
    }

    // Desktop icon grid
    GridView {
        id: desktopGrid
        anchors {
            fill: parent
            margins: 20
            topMargin: 50
        }
        cellWidth: 90
        cellHeight: 90
        flow: GridView.FlowTopToBottom

        model: ListModel {
            ListElement { name: "Files"; icon: "system-file-manager"; exec: "thunar" }
            ListElement { name: "Terminal"; icon: "utilities-terminal"; exec: "alacritty" }
            ListElement { name: "Firefox"; icon: "firefox"; exec: "firefox" }
            ListElement { name: "Settings"; icon: "preferences-system"; exec: "nebula-settings" }
        }

        delegate: Item {
            width: 90
            height: 90

            Column {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 48
                    height: 48
                    radius: 10
                    color: iconMouse.containsMouse ?
                        Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15) :
                        "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: model.name.charAt(0)
                        font.pixelSize: 22
                        font.bold: true
                        color: root.accentColor
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    text: model.name
                    color: root.textColor
                    font.pixelSize: 11
                    font.family: "Inter"
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.5)
                }
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onDoubleClicked: shellController.launchApp(model.exec)
            }
        }
    }
}
