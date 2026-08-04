import QtQuick
import Quickshell.Services.UPower

Row {
    id: root
    spacing: 4

    readonly property var device: UPower.displayDevice
    readonly property bool present: device !== null && device.ready && device.isLaptopBattery
    visible: present

    Text {
        color: {
            if (!root.present) return Colors.subtext0;
            if (root.device.percentage <= 0.2 && UPower.onBattery) return Colors.red;
            return Colors.text;
        }
        font.family: Colors.fontFamily
        font.pixelSize: 14
        text: {
            if (!root.present) return "";
            if (!UPower.onBattery) return "⚡"; // charging / plugged in
            if (root.device.percentage <= 0.2) return "🪫"; // low battery
            return "🔋"; // on battery, healthy
        }
    }

    Text {
        visible: root.present
        color: Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 13
        text: Math.round((root.device?.percentage ?? 0) * 100) + "%"
    }
}
