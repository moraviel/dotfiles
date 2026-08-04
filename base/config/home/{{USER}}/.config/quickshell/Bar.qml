import QtQuick
import Quickshell

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 34
    color: Colors.base

    Rectangle {
        anchors.fill: parent
        color: Colors.base

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Colors.surface0
        }

        // Left: workspaces + active window title
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Workspaces {
                anchors.verticalCenter: parent.verticalCenter
            }

            ActiveWindow {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 400)
            }
        }

        // Center: clock
        ClockWidget {
            anchors.centerIn: parent
        }

        // Right: tray, volume, battery
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            TrayWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            Volume {
                anchors.verticalCenter: parent.verticalCenter
            }

            BatteryWidget {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
