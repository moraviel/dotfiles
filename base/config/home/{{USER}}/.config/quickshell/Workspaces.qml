import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: pillContainer
    color: Colors.surface0
    radius: height / 2
    implicitWidth: row.implicitWidth + 12
    implicitHeight: 22

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: 5

            Rectangle {
                id: wsPill
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                width: 20
                height: 18
                radius: 9
                color: isActive ? Colors.blue : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: wsPill.wsId
                    color: wsPill.isActive ? Colors.crust : Colors.subtext0
                    font.family: Colors.fontFamily
                    font.pixelSize: 12
                    font.bold: wsPill.isActive
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
                }
            }
        }
    }
}
