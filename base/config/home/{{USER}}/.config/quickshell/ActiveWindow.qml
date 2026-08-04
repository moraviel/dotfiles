import QtQuick
import Quickshell.Wayland

Text {
    color: Colors.subtext0
    font.family: Colors.fontFamily
    font.pixelSize: 13
    elide: Text.ElideRight
    text: ToplevelManager.activeToplevel?.title ?? ""
}
