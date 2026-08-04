import QtQuick
import Quickshell.Services.Mpris

Row {
    id: root
    spacing: 6

    readonly property var player: {
        for (const p of Mpris.players.values) {
            if (p.playbackState === MprisPlaybackState.Playing) return p;
        }
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }

    visible: player !== null

    Text {
        color: Colors.mauve
        font.pixelSize: 14
        text: "🎵"
    }

    Text {
        color: Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 13
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 220)
        text: {
            if (!root.player) return "";
            const artist = root.player.trackArtist;
            const title = root.player.trackTitle ?? "";
            return artist ? artist + " – " + title : title;
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!root.player) return;
                if (root.player.playbackState === MprisPlaybackState.Playing) root.player.pause();
                else root.player.play();
            }
        }
    }
}
