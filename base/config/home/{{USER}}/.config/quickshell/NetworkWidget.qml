import QtQuick
import Quickshell.Networking

Row {
    id: root
    spacing: 4

    readonly property var activeNetwork: {
        for (const dev of Networking.devices.values) {
            for (const net of dev.networks.values) {
                if (net.connected) return net;
            }
        }
        return null;
    }

    Text {
        color: Colors.text
        font.pixelSize: 14
        text: {
            if (!root.activeNetwork) return "📡";
            if (root.activeNetwork.signalStrength !== undefined) return "📶";
            return "🔌";
        }
    }

    Text {
        visible: root.activeNetwork !== null
        color: Colors.subtext0
        font.family: Colors.fontFamily
        font.pixelSize: 13
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 140)
        text: root.activeNetwork?.name ?? ""
    }
}
