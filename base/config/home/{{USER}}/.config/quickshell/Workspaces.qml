import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 6

    Repeater {
        model: 5

        Rectangle {
            id: wsPill
            required property int index
            readonly property int wsId: index + 1
            readonly property var ws: {
                for (const w of Hyprland.workspaces.values) {
                    if (w.id === wsId) return w;
                }
                return null;
            }
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
            readonly property bool hasWindows: ws !== null

            width: isActive ? 22 : 14
            height: 14
            radius: 7
            color: isActive ? Colors.mauve : (hasWindows ? Colors.surface1 : Colors.surface0)

            Behavior on width {
                NumberAnimation { duration: 120 }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
            }
        }
    }
}
