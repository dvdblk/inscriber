import sys

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction, QFont, QKeySequence
from PyQt6.QtWidgets import QFileDialog, QLabel, QMainWindow


class MainWindow(QMainWindow):
    """Main Window of the Application."""

    def __init__(self):
        super().__init__()

        self.setWindowTitle("Inscriber annotation tool")
        self.resize(400, 200)
        lbl = QLabel("UwU")
        font = QFont()
        font.setPointSize(32)
        lbl.setFont(font)

        self.central_widget = lbl
        self.central_widget.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.setCentralWidget(self.central_widget)

        self.show()
