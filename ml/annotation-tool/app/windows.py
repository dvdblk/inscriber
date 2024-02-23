import sys

from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QMainWindow, QLabel, QFileDialog
from PyQt6.QtGui import QKeySequence, QAction


class MainWindow(QMainWindow):
    """Main Window of the Application."""

    def __init__(self):
        super().__init__()

        self.setWindowTitle("Inscriber annotation tool")
        self.resize(400, 200)
        self.central_widget = QLabel("Hello, World!")
        self.central_widget.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.setCentralWidget(self.central_widget)

        self._create_actions()
        self._create_menu_bar()

        self.show()

    def _create_actions(self):
        self.open_action = QAction("&Open", self)
        self.open_action.setShortcut(QKeySequence("Ctrl+o"))
        self.open_action.triggered.connect(self.show_file_dialog)

        self.export_action = QAction("&Export", self)
        self.export_action.setShortcut(QKeySequence("Ctrl+e"))

        self.about_action = QAction("About", self)

    def show_file_dialog(self):
        file_dialog = QFileDialog()
        selected_file, _ = file_dialog.getOpenFileName(
            self,
            "Open File",
            "",
            "JSON (*.json)",
        )

        if selected_file:
            print(f"Selected file: {selected_file}")

    def _create_menu_bar(self):
        menu_bar = self.menuBar()

        # Open
        menu_bar.addAction(self.open_action)

        # Export
        menu_bar.addAction(self.export_action)

        # About
        menu_bar.addAction(self.about_action)

        # macOS workaround to display a menubar
        if sys.platform == "darwin":
            menu_bar.setNativeMenuBar(False)
