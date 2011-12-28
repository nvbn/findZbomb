import Qt 4.7

Image {
    fillMode: Image.Tile
    source: 'images/active.png'
    width: 20
    height: 20
    Behavior on x { PropertyAnimation { duration: 300 } }
    Behavior on y { PropertyAnimation { duration: 300 } }
}
