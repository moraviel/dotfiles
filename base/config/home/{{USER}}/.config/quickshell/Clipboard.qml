import QtQuick
import Quickshell.Io

Text {
    color: Colors.text
    font.pixelSize: 14
    text: "📋"

    Process {
        id: pickerProcess
        command: ["sh", "-c", "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: pickerProcess.startDetached()
    }
}
