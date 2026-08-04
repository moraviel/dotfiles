import QtQuick
import Quickshell

PanelWindow {
    id: bar

    property bool powerMenuOpen: false

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

        // Left: distro logo, workspaces, active window title
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "assets/arch-logo.svg"
                sourceSize.width: 18
                sourceSize.height: 18
                width: 18
                height: 18
            }

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

        // Right: tray, media, notifications, clipboard, bluetooth, network, volume, battery, power
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            TrayWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            Media {
                anchors.verticalCenter: parent.verticalCenter
            }

            Notifications {
                anchors.verticalCenter: parent.verticalCenter
            }

            Clipboard {
                anchors.verticalCenter: parent.verticalCenter
            }

            BluetoothWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            NetworkWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            Volume {
                anchors.verticalCenter: parent.verticalCenter
            }

            BatteryWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: powerButton
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.text
                font.pixelSize: 14
                text: "⏻"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.powerMenuOpen = !bar.powerMenuOpen
                }
            }
        }
    }

    PowerMenu {
        anchor.window: bar
        anchor.rect.x: bar.width - implicitWidth - 12
        anchor.rect.y: bar.height
        visible: bar.powerMenuOpen
    }
}
