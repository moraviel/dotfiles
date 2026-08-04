import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    spacing: 8

    Repeater {
        model: SystemTray.items

        Image {
            required property SystemTrayItem modelData
            source: modelData.icon
            width: 16
            height: 16

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) parent.modelData.activate();
                    else parent.modelData.secondaryActivate();
                }
            }
        }
    }
}
