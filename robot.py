from PySide.QtCore import QObject, Signal, Slot
import time
from PySide.QtScript import QScriptEngine

class BaseRobot(QObject):
    LEFT = (0, -1)
    TOP_LEFT = (-1, -1)
    TOP = (-1, 0)
    TOP_RIGHT = (-1, 1)
    RIGHT = (0, 1)
    BOTTOM_RIGHT = (1, 1)
    BOTTOM = (1, 0)
    BOTTOM_LEFT = (1, -1)

    move = Signal(bool)
    start = Signal()

    def __init__(self, map):
        QObject.__init__(self)
        self.map = map
        self.map.put_robot(self)
        self.start.connect(self._start)
        self.move.connect(self._move)
        self.stop = False

    @property
    def position(self):
        return self.map.position

    def get_pos(self, to):
        return self.position[0] + to[0], self.position[1] + to[1]

    def watch(self, to):
        return self.map.get(
            self.get_pos(to)
        )

    def go(self, to):
        self.map.go(self.get_pos(to))

    def remove_bomb(self, to):
        self.map.remove_bomb(self.get_pos(to))

    @Slot(bool)
    def _move(self, status):
        if not self.stop:
            time.sleep(0.4)
            self.on_move(status)

    @Slot()
    def _start(self):
        if not self.stop:
            self.on_start()


    def on_move(self, status):
        raise NotImplementedError

    def on_start(self):
        raise NotImplementedError
