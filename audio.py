from PySide.QtCore import QObject, Slot
from PySide.phonon import Phonon

class Sounder(QObject):
    def __init__(self, *args, **kwargs):
        QObject.__init__(self, *args, **kwargs)
        self.audioOuptut = Phonon.AudioOutput(Phonon.MusicCategory, self)
        self.player = Phonon.MediaObject(self)
        Phonon.createPath(self.player, self.audioOuptut)

    @Slot()
    def boom(self):
        self.player.setCurrentSource(Phonon.MediaSource('sound/boom.wav'))
        self.player.play()

    @Slot()
    def win(self):
        self.player.setCurrentSource(Phonon.MediaSource('sound/win.wav'))
        self.player.play()

