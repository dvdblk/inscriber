import sys

from PyQt6.QtCore import QObject, Qt, pyqtSignal
from PyQt6.QtGui import QAction, QKeySequence
from PyQt6.QtWidgets import QFileDialog, QLabel, QMainWindow


class MenuController(QObject):
    """Controller for the main menu bar"""

    file_opened = pyqtSignal(str)
    """Signal to notify the opening of a JSON file."""

    def __init__(self, main_window, app):
        super().__init__()
        self.main_window = main_window
        self.app = app

        self._create_actions()
        self._create_menu_bar()

    def _create_actions(self):
        self.open_action = QAction("&Open", self.main_window)
        self.open_action.setShortcut(QKeySequence("Ctrl+o"))
        self.open_action.triggered.connect(self.show_file_dialog)

        self.export_action = QAction("&Export", self.main_window)
        self.export_action.setShortcut(QKeySequence("Ctrl+e"))

        self.about_action = QAction("About", self.main_window)

    def _create_menu_bar(self):
        menu_bar = self.main_window.menuBar()

        # Open
        menu_bar.addAction(self.open_action)

        # Export
        menu_bar.addAction(self.export_action)

        # About
        menu_bar.addAction(self.about_action)

        # macOS workaround to display a menubar
        if sys.platform == "darwin":
            menu_bar.setNativeMenuBar(False)

    def show_file_dialog(self):
        file_dialog = QFileDialog()
        selected_file_path, _ = file_dialog.getOpenFileName(
            self.main_window,
            "Open File",
            "",
            "JSON (*.json)",
        )

        # emit signal
        if selected_file_path:
            self.file_opened.emit(selected_file_path)


class MainContoller:
    def __init__(self, model, view, menu_controller) -> None:
        self.model = model
        self.view = view
        self.menu_controller = menu_controller

        self.menu_controller.file_opened.connect(self.handle_file_opened)

    def handle_file_opened(self, file_path: str):
        print(f"File opened: {file_path}")
