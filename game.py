#!/usr/bin/python
import os
from PySide.QtCore import QObject, QThread, Signal, Slot, QTimer, QSettings, Qt
from PySide.QtDeclarative import QDeclarativeView
from PySide.QtGui import QApplication, QMainWindow, QIcon
import sys
from audio import Sounder
from maps import Map, Block, Bomb, Space
from robot import BaseRobot

class Game(QObject):

    def __init__(self, app):
        QObject.__init__(self)
        self.app = app

    def put_map(self, map):
        self.map = map
        self.map.failed.connect(self.boom)


class RoboThread(QThread):
    def run(self, *args, **kwargs):
        game_app._start()
        self.exec_()


class GameApp(QDeclarativeView):
    block_tpls = {
        Block: 'blocks/block.qml',
        Bomb: 'blocks/bomb.qml',
        Space: 'blocks/space.qml',
    }
    #current = 'blocks/active.qml'
    mega_start = Signal()

    def __init__(self, menu, settings, *args, **kwargs):
        QDeclarativeView.__init__(self, *args, **kwargs)
        self.sound = Sounder()
        self.menu = menu
        self.settings = settings
        self.menu.rootObject().initial_map(self.settings.value('map', 'simple'))
        self.rt_pool = []#fix fault
        self.setWindowTitle('findZbomb!')
        self.setSource('interface.qml')
        self.set_map(None)
        self.redraw()
        context = self.rootContext()
        context.setContextProperty('obj', self)
        self.mega_start.connect(self._mega_start)
        self.setResizeMode(QDeclarativeView.SizeRootObjectToView)
        code = self.settings.value('code')
        if code:
            self.rootObject().set_code(code)

    def set_map(self, map_path):
        if map_path:
            map_name = map_path.split('/')[-1]
            self.settings.setValue('map', map_name)
            self.rootObject().set_map_name(map_name)
        self.map_path = map_path
        self.old_cp = None
        self.game = Game(self)
        self.map = Map(self.game, map_path)
        self.map.failed.connect(self.sound.boom)
        self.map.failed.connect(self.failed)
        self.map.finished.connect(self.sound.win)
        self.map.finished.connect(self.win)
        if getattr(self, 'rt', None):
            self.rt.quit()
        try:
            self.robot.stop = True
        except AttributeError:
            pass
        self.rt = RoboThread()
        self.rt_pool.append(self.rt)

    def draw_map(self):
        #grid = self.rootContext().contextProperty('mapGrid')
        root = self.rootObject()
        prepared_map = map(lambda items:
            map(lambda item: self.block_tpls[type(item)], items),
        self.map.map)
        root.draw_map(prepared_map)
        self.rootObject().robot_to_active_pos(*self.map.position)

        #print grid

    def redraw(self):
        if self.old_cp != self.map.cur_position:
            self.draw_map()
            self.old_cp = self.map.cur_position
            if hasattr(self, 'robot'):
                self.rootObject().set_map_count(self.robot.moves)
                self.rootObject().robot_to_active_pos(*self.robot.position)
        QTimer.singleShot(300, self.redraw)

    @Slot(result=int)
    def start(self):
        self.set_map(self.map_path)
        self.rootObject().remove_notify()
        self.code = 'class Robot(BaseRobot):\n%s' % self.rootObject().get_code()
        self.mega_start.emit()
        return 0

    @Slot()
    def _mega_start(self):
        self.rt.start()

    def _start(self):
        Robot = BaseRobot#fix code highlighting
        exec(self.code)
        self.robot = Robot(self.map)
        self.map.put_robot(self.robot)

    @Slot()
    def failed(self):
        self.rootObject().failed()
        self.set_map(self.map_path)

    @Slot()
    def win(self):
        self.rootObject().win()
        self.set_map(self.map_path)

    @Slot(str)
    def upd_code(self, code):
        self.settings.setValue('code', code)
        self.settings.sync()

    def show_menu(self):
        self.hide()
        self.menu.show()

    def keyReleaseEvent(self, event):
        if event.key() == Qt.Key_Escape:
            self.show_menu()
        else:
            self.upd_code(self.rootObject().get_code())  # fix shit with events
            event.setAccepted(False)

class Menu(QDeclarativeView):

    def __init__(self, *args, **kwargs):
        QDeclarativeView.__init__(self, *args, **kwargs)
        context = self.rootContext()
        context.setContextProperty('menu', self)
        self.setSource('menu.qml')
        self.setResizeMode(QDeclarativeView.SizeRootObjectToView)

    @Slot(str)
    def start_game(self, map_path):
        game_app.show()
        game_app.set_map(map_path)
        self.game_app = game_app
        self.hide()

    @Slot(str)
    def resume_game(self, map_path):
        if self.game_app.map_path != map_path:
            self.game_app.set_map(map_path)
        self.hide()
        self.game_app.show()

    @Slot(str, result=str)
    def next_map(self, current):
        maps = os.listdir('maps')
        try:
            return maps[maps.index(current) + 1]
        except (IndexError, ValueError):
            return maps[0]

    @Slot(result=int)
    def check(self):
        return int(hasattr(self, 'game_app'))

    @Slot()
    def exit(self):
        self.game_app.settings.sync()
        sys.exit()

    @Slot(result=str)
    def readme(self):
        with open('README.html') as readme_file:
            return readme_file.read()


class Window(QMainWindow):
    def __init__(self, menu, game_app):
        QMainWindow.__init__(self)
        self.menu = menu
        self.game_app = game_app
        self.layout().addWidget(menu)
        self.layout().addWidget(game_app)
        self.setMinimumSize(800, 500)

    def resizeEvent(self, *args, **kwargs):
        self.menu.resize(self.size())
        self.game_app.resize(self.size())


if __name__ == '__main__':
    app = QApplication(sys.argv)
    m = Menu()
    settings = QSettings('0GNM', 'findZbomb')
    game_app = GameApp(m, settings)
    game_app.hide()
    widget = Window(m, game_app)
    widget.setWindowIcon(QIcon('images/bomb.png'))
    widget.setWindowTitle('findZbomb!')
    widget.show()
    try:
        app.exec_()
    except Exception, e:
        print e
    finally:
        game_app.settings.sync()
        sys.exit(0)

