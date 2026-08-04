import QtQuick
import Quickshell.Bluetooth

Row {
    id: root
    spacing: 4

    readonly property bool btEnabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property int connectedCount: {
        let n = 0;
        for (const d of Bluetooth.devices.values) {
            if (d.connected) n++;
        }
        return n;
    }

    Text {
        color: root.btEnabled ? (root.connectedCount > 0 ? Colors.blue : Colors.text) : Colors.overlay0
        font.pixelSize: 14
        text: "🔵"
    }

    Text {
        visible: root.connectedCount > 0
        color: Colors.subtext0
        font.family: Colors.fontFamily
        font.pixelSize: 13
        text: root.connectedCount
    }
}
