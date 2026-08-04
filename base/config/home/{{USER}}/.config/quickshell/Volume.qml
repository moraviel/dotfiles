import QtQuick
import Quickshell.Services.Pipewire

Row {
    spacing: 4

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? true
    readonly property real volume: sink?.audio?.volume ?? 0

    PwObjectTracker {
        objects: [sink]
    }

    Text {
        color: muted ? Colors.overlay0 : Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 14
        text: {
            if (muted || volume <= 0) return "🔇"; // 🔇
            if (volume < 0.5) return "🔉";          // 🔉
            return "🔊";                             // 🔊
        }
    }

    Text {
        visible: sink !== null
        color: muted ? Colors.overlay0 : Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 13
        text: Math.round(volume * 100) + "%"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
        }
        onWheel: (wheel) => {
            if (!sink || !sink.audio) return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta));
        }
    }
}
