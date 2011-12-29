import Qt 4.7

Rectangle {
    id: main
    width: 800
    height: 500
    x: 0
    y: 0
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: 'images/bg_menu.png'
    }
    FontLoader {
        id: 'bitFont'
        source: '8bit.ttf'
    }
    Rectangle {
        id: menuRect
        width: 300
        height: 200
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Rectangle {
            id: 'mapName'
            color: '#ffffff'
            width: parent.width
            height: 50
            anchors.top: parent.top
            anchors.left: parent.left
            Text {
                id: 'mapNameTxt'
                anchors.fill: parent
                color: '#00ff00'
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: bitFont.name
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mapNameTxt.text = menu.next_map()
                }
            }
        }
        Rectangle {
            id: 'startBtn'
            color: '#0000ff'
            width: parent.width
            height: 50
            anchors.top: mapName.bottom
            anchors.left: parent.left
            border.color: '#ffff00'
            border.width: 2
            Text {
                id: 'startBtnTxt'
                color: '#00ffff'
                text: 'START'
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 16
                font.family: bitFont.name
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    startBtnTxt.text = 'RESUME'
                    if (menu.check())
                        menu.resume_game()
                    else
                        menu.start_game()
                }
            }
        }
        Rectangle {
            id: 'optBtn'
            color: '#0000ff'
            width: parent.width
            height: 50
            anchors.top: startBtn.bottom
            anchors.left: parent.left
            border.color: '#ffff00'
            border.width: 2
            Text {
                color: '#00ffff'
                text: 'HELP'
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 16
                font.family: bitFont.name
            }
        MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuRect.visible = false
                    helpRect.visible = true
                }
            }
        }
        Rectangle {
            id: 'exitBtn'
            color: '#0000ff'
            width: parent.width
            height: 50
            anchors.top: optBtn.bottom
            anchors.left: parent.left
            border.color: '#ffff00'
            border.width: 2
            Text {
                color: '#00ffff'
                text: 'EXIT'
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 16
                font.family: bitFont.name
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menu.exit()
                }
            }
        }
    }
    function initial_map(map) {
        mapNameTxt.text = map
    }
    Rectangle {
        id: helpRect
        x: 50
        y: 50
        visible: false
        width: parent.width - 100
        height: parent.height - 100
        color: '#000000'
        Flickable {
            anchors.fill: parent
            clip: true
            Text {
                id: helpText
                color: '#ffffff'
                text: menu.readme()
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.leftMargin: 10
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                helpRect.visible = false
                menuRect.visible = true
            }
        }
    }
}
