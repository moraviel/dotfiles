import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    NotificationServer {
        id: notifServer
        keepOnReload: true
        bodySupported: true
        imageSupported: true
    }

    Row {
        id: row
        spacing: 2

        Text {
            color: notifServer.trackedNotifications.count > 0 ? Colors.yellow : Colors.subtext0
            font.pixelSize: 14
            text: "🔔"
        }

        Text {
            visible: notifServer.trackedNotifications.count > 0
            color: Colors.yellow
            font.family: Colors.fontFamily
            font.pixelSize: 12
            text: notifServer.trackedNotifications.count
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // Clears tracked notifications. There's no dropdown/history view yet —
        // this is a basic unread-count indicator, not a full notification center.
        onClicked: {
            for (const n of notifServer.trackedNotifications.values) n.dismiss();
        }
    }
}
