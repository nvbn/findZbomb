import Qt 4.7

Rectangle {
    id: main
    width: 800
    height: 600
    FontLoader {
        id: bitFont
        source: '8bit.ttf'
    }
    Rectangle {
        id: topPanel
        x: 0
        y: 0
        width: parent.width
        height: 50
        color: '#0000ff'
        Rectangle {
            id: mapName
            width: 300
            anchors.left: parent.left
            anchors.top:  parent.top
            anchors.bottom:  parent.bottom
            color: parent.color
            property string  name
            Text {
                color: '#ffff00'
                anchors.fill: parent
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: bitFont.name
                verticalAlignment: Text.AlignVCenter
                text: 'map: ' + parent.name
            }
        }
        Rectangle {
            id: mapMoves
            width: 300
            anchors.right: parent.right
            anchors.top:  parent.top
            anchors.bottom:  parent.bottom
            color: parent.color
            property int count: 0
            Text {
                color: '#ffff00'
                anchors.fill: parent
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: bitFont.name
                verticalAlignment: Text.AlignVCenter
                text: 'moves: ' + parent.count
            }
        }
    }
    Rectangle {
        id: editorHolder
        width: 300
        height: parent.height - 100
        color: '#000000'
        y: 50
        Flickable {
            id: flickaEditor
            width: parent.width
            height: parent.height
            x: 10
            y: 10
            contentWidth: codeEditor.width
            contentHeight: clsName.height + codeEditor.height
            clip: true

            function ensureVisible(r) {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }
            Text {
                id: clsName
                color: '#ffffff'
                height: 20
                anchors.bottom: codeEditor.top
                text: 'class Robot(BaseRobot):'
                font.family: 'Monospace'
                font.pointSize: 9
            }
            TextEdit {
                id: codeEditor
                color: '#ffffff'
                anchors.top: clsName.bottom
                text: '    def on_start(self):\n        self.go(self.RIGHT)\n\n    def on_move(self, status):\n        self.go(self.RIGHT)\n\n'
                onCursorRectangleChanged: flickaEditor.ensureVisible(cursorRectangle)
                font.pointSize: 9
                font.family: 'Monospace'
                selectByMouse: true
                selectedTextColor: '#000000'
                selectionColor: '#a9a9a9'
                ContextMenu {
                    target: parent
                    main_obj: main
                }
                Keys.onPressed: {
                    if (event.key == Qt.Key_Tab) {
                        var position = codeEditor.cursorPosition
                        var start = codeEditor.text.substr(0, position)
                        var end = codeEditor.text.substr(position)
                        codeEditor.text = start + '    ' + end
                        codeEditor.cursorPosition = position + 4
                        event.accepted = true
                    } else if (event.key == Qt.Key_Backspace) {
                        var position = codeEditor.cursorPosition
                        if (codeEditor.text.substr(position - 4, 4) == '    ') {
                            var start = codeEditor.text.substr(0, position - 4)
                            var end = codeEditor.text.substr(position)
                            codeEditor.text = start + end
                            codeEditor.cursorPosition = position - 4
                            event.accepted = true
                        }
                    } else if (event.key == Qt.Key_Delete) {
                        var position = codeEditor.cursorPosition
                        if (codeEditor.text.substr(position, 4) == '    ') {
                            var start = codeEditor.text.substr(0, position)
                            var end = codeEditor.text.substr(position + 4)
                            codeEditor.text = start + end
                            event.accepted = true
                            codeEditor.cursorPosition = position
                        }
                    } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        var position = codeEditor.cursorPosition
                        var prev = codeEditor.text.substr(0, position)
                        try {
                            var lines = prev.match(/^.*((\r\n|\n|\r)|$)/gm)
                            var last_line = lines[lines.length - 1]
                        } catch(error) {
                            var last_line = prev
                            console.log('first line enter')
                        }
                        var spaces = last_line.match(/^ */gm)[0]
                        if (last_line.search(':') != -1) {
                            spaces += '    '
                        }
                        var end = codeEditor.text.substr(position)
                        codeEditor.text = prev + '\r\n' + spaces + end
                        event.accepted = true
                        codeEditor.cursorPosition = position + 1 + spaces.length
                    }
                }
            }
        }
    }
    Rectangle {
        id: mapHolder
        x: 300
        y: 50
        width: parent.width - 300
        height: parent.height - 100
        Image {
            anchors.fill: parent
            fillMode: Image.Tile
            source: 'images/space.png'
        }
        Flickable {
            anchors.fill: parent
            contentWidth: mapGraph.width
            contentHeight: mapGraph.height
            clip: true
            Rectangle {
                id: mapGraph
                anchors.leftMargin: 50
                anchors.topMargin: 50
                anchors.fill: parent
                color: 'transparent'
                Grid {
                    id: mapGrid
                    anchors.fill: parent
                }
                Image {
                    id: mapBkg
                    visible: false
                    anchors.top: mapGrid.top
                    anchors.left:  mapGrid.left
                    fillMode: Image.Tile
                }
                Robot {
                    id: robotObj
                    visible: false
                }
            }
        }
    }
    function draw_map(map) {
        for (var i = 0; i < mapGrid.children.length; i++) {
            mapGrid.children[i].destroy()
        }
        var h = map.length
        var w = map[0].length
        mapGrid.rows = h
        mapGrid.columns = w
        var num = 0
        mapGrid.visible = true
        mapBkg.visible = false
        for (var i = 0; i < h; i++) {
            for (var y = 0; y < w; y++) {
                var block = Qt.createComponent(map[i][y])
                block.createObject(mapGrid)
                num++
            }
        }
    }
    function robot_to_active_pos(i, y) {
        var num = i * mapGrid.columns + y
        var block = mapGrid.children[num]
        robotObj.visible = true
        robotObj.x = block.x
        robotObj.y = block.y
    }
    function failed() {
        bombedNotify.visible = true
        robotObj.visible = false
        notifyBox.visible = true
    }
    function win() {
        robotObj.visible = false
        winNotify.visible = true
        notifyBox.visible = true
    }
    function notify_exception() {
        notifyException.visible = true
        notifyBox.visible = true
    }
    function get_code() {
        return codeEditor.text
    }
    function set_code(code) {
        return codeEditor.text = code
    }
    function remove_notify() {
        bombedNotify.visible = false
        winNotify.visible = false
        notifyBox.visible = false
    }
    function set_map_name(map_name) {
        mapName.name = map_name
    }
    function set_map_count(count) {
        mapMoves.count = count
    }
    function set_custom_background(bkg) {
        mapBkg.source = bkg
        mapBkg.visible = true
        mapBkg.width = mapGrid.columns * 20
        mapBkg.height = mapGrid.rows * 20
        mapGrid.visible = false
    }

    Rectangle {
        id: notifyBox
        visible: false
        x: main.width / 2 - 175
        y: main.height / 2 - 60
        width: 350
        height: 100
        color: '#ff0000'
        z: 100
        Text {
            id: bombedNotify
            visible: false
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: '#00ff00'
            font.pointSize: 24
            font.family: bitFont.name
            text: 'Your bombed'
        }
        Text {
            id: winNotify
            visible: false
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: '#00ff00'
            text: 'Your win'
            font.pointSize: 24
            font.family: bitFont.name
        }
        Text {
            id: notifyException
            visible: false
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: '#00ff00'
            text: 'Exception'
            font.pointSize: 24
            font.family: bitFont.name
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                remove_notify()
            }
        }
    }
    Rectangle {
        x: 0
        y: main.height - 50
        color: '#000000'
        height: 50
        width: main.width
        Rectangle {
            id: startBtn
            anchors.fill: parent
            color: '#0000ff'
            width: 100
            height: 50
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    obj.start()
                }
            }
            Text {
                text: 'Run'
                color: '#ffff00'
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: bitFont.name
                font.pointSize: 24
            }
        }
    }
    Rectangle {
        id: resizer
        width: 10
        height: editorHolder.height
        color: '#a9a9a9'
        x: editorHolder.width - 5
        anchors.verticalCenter:  editorHolder.verticalCenter
        MouseArea {
            anchors.fill: parent
            drag.target: resizer
            drag.axis: Drag.XAxis
            onPositionChanged: {
                editorHolder.width = resizer.x + 5
                mapHolder.x =  resizer.x + 5
                mapHolder.width = main.width - mapHolder.x
            }
        }
    }
}
