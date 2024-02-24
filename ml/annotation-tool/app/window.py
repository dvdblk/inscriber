import sys

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction, QFont, QKeySequence
from PyQt6.QtWidgets import QFileDialog, QLabel, QMainWindow


class MainWindow(QMainWindow):
    """Main Window of the Application."""

    def __init__(self):
        super().__init__()

        self.setWindowTitle("Inscriber annotation tool")
        self.resize(756, 340)

        self.show()
