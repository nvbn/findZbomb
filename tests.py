from PySide.QtCore import QCoreApplication
from maps import Map
from robot import BaseRobot
from game import Game
import unittest
import sys


class Robot(BaseRobot):
    def on_start(self):
        self.go(self.RIGHT)

    def on_move(self, status):
        if status:
            self.go(self.RIGHT)
        print self.watch(self.RIGHT)



if __name__ == '__main__':
    app = QCoreApplication(sys.argv)
    g = Game()
    m = Map(g)
    r = Robot(m)
    m.put_robot(r)