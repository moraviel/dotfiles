import QtQuick

Text {
    id: root
    color: Colors.text
    font.family: Colors.fontFamily
    font.pixelSize: 13

    function refresh() {
        root.text = Qt.formatDateTime(new Date(), "hh:mm");
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
