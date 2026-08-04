import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

PopupWindow {
    id: popup
    implicitWidth: 180
    implicitHeight: column.implicitHeight + 16
    visible: false
    grabFocus: true

    Rectangle {
        anchors.fill: parent
        color: Colors.mantle
        radius: 8
        border.color: Colors.surface0
        border.width: 1

        Column {
            id: column
            anchors.centerIn: parent
            width: parent.width - 16
            spacing: 2

            PowerMenuButton {
                label: "🔒  Lock"
                onActivated: {
                    lockProcess.startDetached();
                    popup.visible = false;
                }
            }
            PowerMenuButton {
                label: "🚪  Log out"
                onActivated: {
                    Hyprland.dispatch("exit");
                    popup.visible = false;
                }
            }
            PowerMenuButton {
                label: "🔄  Reboot"
                onActivated: {
                    rebootProcess.startDetached();
                    popup.visible = false;
                }
            }
            PowerMenuButton {
                label: "⏻  Shutdown"
                onActivated: {
                    shutdownProcess.startDetached();
                    popup.visible = false;
                }
            }
        }
    }

    Process {
        id: lockProcess
        command: ["hyprlock"]
    }
    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }
    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }
}
