import Qt 4.7

MouseArea {
    property variant target
    property variant main_obj
    anchors.fill: target
    acceptedButtons: Qt.RightButton
    z: 40
    Rectangle {
        id: contextMenu
        visible: false
        width: 100
        height: 80
        z: 50
        color: '#000000'
        Rectangle {
            id: cutBtn
            property bool enabled: true
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            border.width: 2
            border.color:  '#ffffff'
            color: enabled ? '#000000' : '#a9a9a9'
            height: 20
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: '#ffffff'
                text: 'Cut'
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (enabled) {
                        target.cut()
                        kill()
                    }
                }
            }
        }
        Rectangle {
            id: copyBtn
            property bool enabled: true
            anchors.top: cutBtn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            border.width: 2
            border.color:  '#ffffff'
            color: enabled ? '#000000' : '#a9a9a9'
            height: 20
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: '#ffffff'
                text: 'Copy'
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (enabled) {
                        target.copy()
                        kill()
                    }
                }
            }
        }
        Rectangle {
            id: pasteBtn
            property bool enabled: true
            anchors.top: copyBtn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            border.width: 2
            border.color:  '#ffffff'
            color: enabled ? '#000000' : '#a9a9a9'
            height: 20
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: '#ffffff'
                text: 'Paste'
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (enabled) {
                        target.paste()
                        kill()
                    }
                }
            }
        }
        Rectangle {
            id: selectallBtn
            property bool enabled: true
            anchors.top: pasteBtn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            border.width: 2
            border.color:  '#ffffff'
            color: enabled ? '#000000' : '#a9a9a9'
            height: 20
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: '#ffffff'
                text: 'Select All'
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (enabled) {
                        target.selectAll()
                        kill()
                    }
                }
            }
        }
    }
    onClicked: {
        if (contextMenu.visible) {
            kill()
        } else {
            x = main_obj.x
            y = main_obj.y
            width = main_obj.width
            height = main_obj.height
            contextMenu.visible = true
            contextMenu.x = mouseX
            contextMenu.y = mouseY
            cutBtn.enabled = Boolean(target.selectedText.length)
            copyBtn.enabled = Boolean(target.selectedText.length)
            pasteBtn.enabled = target.canPaste
            acceptedButtons = Qt.LeftButton | Qt.RightButton
        }
    }
    function kill() {
        contextMenu.visible = false
        anchors.fill = target
        acceptedButtons = Qt.RightButton
    }
}
