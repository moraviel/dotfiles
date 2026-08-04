import QtQuick

Row {
    spacing: 6

    Text {
        id: timeText
        color: Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 13
        font.bold: true
    }

    Text {
        id: dateText
        color: Colors.subtext0
        font.family: Colors.fontFamily
        font.pixelSize: 13
    }

    function refresh() {
        const now = new Date();
        timeText.text = Qt.formatDateTime(now, "hh:mm");
        dateText.text = Qt.formatDateTime(now, "ddd, d MMM");
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: refresh()
    }
}
