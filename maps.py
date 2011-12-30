import json
from PySide.QtCore import QObject, Signal, Slot
import os
import re

class BaseBlock(object):
    def __init__(self, map, x, y):
        self.map = map
        self.x = x
        self.y = y
        self.used = False

    def stap(self):
        raise NotImplementedError

    @property
    def position(self):
        return self.x, self.y

    def __repr__(self):
        return '<%s at x=%d y=%d>' % (
            self.__class__.__name__,
            self.x, self.y,
        )


class Bomb(BaseBlock):
    def stap(self):
        if not getattr(self, 'used', False):
            self.map.failed.emit()
        else:
            self.map.robot.move.emit(True)

    def repair(self):
        self.used = True


class Block(BaseBlock):
    def stap(self):
        self.map.robot.move.emit(False)


class Space(BaseBlock):
    def stap(self):
        self.map.cur_position = self.position
        self.map.cur_block = self
        self.used = True
        self.map.robot.move.emit(True)


class Map(QObject):
    ELEM_BY_TYPE = {
        '#': Block,
        '!': Bomb,
        ' ': Space,
    }
    failed = Signal()
    finished = Signal()

    def __init__(self, game, path=None):
        if not (path and os.path.isfile(path)):
            path = 'maps/simple.json'
        QObject.__init__(self)
        self.game = game
        game.map = self
        spec = Map.read_spec(path)
        path = 'maps/' + spec['path']
        with open(path) as data_map:
            tmp_map = data_map.read()
        self.map = []
        self.bombs = 0
        for y, line in enumerate(tmp_map.split('\n')):
            _line = []
            for x, item in enumerate(line):
                block = Map.ELEM_BY_TYPE[item](self, y, x)
                _line.append(block)
                if not hasattr(self, 'initial_position') and type(block) is Space:
                    self.initial_position = block.position
                    self.cur_position = block.position
                    self.cur_block = block
                if type(block) is Bomb:
                    self.bombs += 1
                    self.bomb = block
            self.map.append(_line)
        self.title = spec.get('title', spec['path'])
        self.background = spec.get('background', None)
        if self.background:
            self.background = 'maps/' + self.background

    @staticmethod
    def read_spec(path):
        with open(path) as data_file:
            return json.loads(
                re.sub('[\n\t]', '', data_file.read())
            )

    def put_robot(self, robot):
        self.robot = robot
        self.robot.start.emit()

    @property
    def position(self):
        return self.cur_position

    @property
    def block(self):
        return self.cur_block

    def get(self, pos):
        if not (self.position[0] - pos[0] in (-1, 0, 1) and self.position[1] - pos[1] in (-1, 0, 1)):
            raise Exception('Big moves not allowed!')
        try:
            return self.map[pos[0]][pos[1]]
        except IndexError:
            return Block(self, *pos)

    def remove_bomb(self, pos):
        block = self.get(pos)
        if type(block) is Bomb:
            print self.bombs
            block.repair()
            self.bombs -= 1
            if not self.bombs:
                self.finished.emit()

    def compass(self):
        point = [0, 0]
        if self.position[0] > self.bomb.x:
            point[0] = -1
        elif self.position[0] < self.bomb.x:
            point[0] = 1
        elif self.position[0] == self.bomb.x:
            point[0] = 0
        if self.position[1] > self.bomb.y:
            point[1] = -1
        elif self.position[1] < self.bomb.y:
            point[1] = 1
        elif self.position[1] == self.bomb.y:
            point[1] = 0
        return tuple(point)


    def go(self, pos):
        block = self.get(pos)
        block.stap()
