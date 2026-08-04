import QtQuick

Rectangle {
    id: root
    property string label: ""
    signal activated()

    width: parent ? parent.width : implicitWidth
    height: 32
    radius: 6
    color: mouseArea.containsMouse ? Colors.surface1 : "transparent"

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: Colors.text
        font.family: Colors.fontFamily
        font.pixelSize: 13
        text: root.label
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
