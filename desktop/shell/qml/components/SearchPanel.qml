import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GlassBackground {
    id: searchPanel

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.95
    transformOrigin: Item.Bottom

    Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Search input
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 24
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06)
            border.width: 2
            border.color: root.accentColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 12

                Text {
                    text: "\u{1F50D}"
                    font.pixelSize: 18
                }

                TextInput {
                    id: searchField
                    Layout.fillWidth: true
                    color: root.textColor
                    font.pixelSize: 15
                    font.family: "Inter"
                    focus: searchPanel.visible
                    clip: true

                    Text {
                        anchors.fill: parent
                        visible: !searchField.text
                        text: "Type to search everywhere..."
                        color: root.textSecondary
                        font.pixelSize: 15
                        font.family: "Inter"
                        verticalAlignment: Text.AlignVCenter
                    }

                    onTextChanged: searchProvider.search(text)
                }
            }
        }

        // Category tabs
        Row {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: ["All", "Apps", "Files", "Settings", "Web"]
                delegate: Rectangle {
                    width: tabText.width + 20
                    height: 32
                    radius: 16
                    color: index === 0 ? root.accentColor :
                        (tabMouse.containsMouse ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08) : "transparent")

                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: modelData
                        color: index === 0 ? "#ffffff" : root.textColor
                        font.pixelSize: 12
                        font.family: "Inter"
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // Results list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: searchProvider.results

            delegate: Rectangle {
                width: ListView.view.width
                height: 52
                radius: 8
                color: resultMouse.containsMouse ?
                    Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06) : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 8
                        color: {
                            var type = modelData.type || "other"
                            if (type === "application") return "#4488ff"
                            if (type === "file") return "#44bb88"
                            if (type === "setting") return "#ff8844"
                            return root.accentColor
                        }
                        Text {
                            anchors.centerIn: parent
                            text: {
                                var type = modelData.type || "other"
                                if (type === "application") return "\u{1F4E6}"
                                if (type === "file") return "\u{1F4C4}"
                                if (type === "setting") return "\u2699"
                                return "\u{1F50D}"
                            }
                            font.pixelSize: 16
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
                            font.bold: true
                        }
                        Text {
                            text: modelData.path || modelData.type || ""
                            color: root.textSecondary
                            font.pixelSize: 11
                            font.family: "Inter"
                            elide: Text.ElideMiddle
                            width: parent.width
                        }
                    }
                }

                MouseArea {
                    id: resultMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        shellController.launchApp(modelData.id || modelData.path)
                        shellController.searchVisible = false
                    }
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: searchProvider.results.length === 0 && searchField.text.length > 0
                text: "No results found"
                color: root.textSecondary
                font.pixelSize: 14
                font.family: "Inter"
            }
        }
    }
}
