import json
import sys

from app.model import LabelledInstance
from app.view import MainView
from PyQt6.QtCore import QObject, pyqtSignal
from PyQt6.QtGui import QAction, QKeySequence
from PyQt6.QtWidgets import QFileDialog


class MenuController(QObject):
    """Controller for the main menu bar"""

    file_opened = pyqtSignal(str)
    """Signal to notify the opening of a JSON file."""
    export_initiated = pyqtSignal()

    def __init__(self, main_window, app):
        super().__init__()
        self.main_window = main_window
        self.app = app

        self._create_actions()
        self._create_menu_bar()

    def _create_actions(self):
        """Create actions for the menu bar."""
        self.open_action = QAction("&Open", self.main_window)
        self.open_action.setShortcut(QKeySequence("Ctrl+o"))
        self.open_action.triggered.connect(self.show_file_dialog)

        self.export_action = QAction("&Export", self.main_window)
        self.export_action.setShortcut(QKeySequence("Ctrl+e"))
        self.export_action.triggered.connect(self.export_initiated.emit)

        self.about_action = QAction("About", self.main_window)

    def _create_menu_bar(self):
        """Create the menu bar and add actions to it."""
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
        """Show a system file dialog to open a JSON file and emit a signal with the file path."""
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
    def __init__(self, model, view: MainView, menu_controller) -> None:
        self.model = model
        self.view = view
        self.menu_controller = menu_controller

        # Connect file open and export signals
        self.menu_controller.file_opened.connect(self.handle_file_opened)
        self.menu_controller.export_initiated.connect(self.handle_export_initiated)

        # Selection sync
        self.view.unlabelled_list_view.clicked.connect(self.did_click_unlabelled_list)
        self.view.labelled_list_view.clicked.connect(self.did_click_labelled_list)

        # Button click
        self.view.selected_instance_button.clicked.connect(self.did_click_add_to_labelled)

        # Connect points changed signal
        self.view.selected_instance_view.points_changed.connect(self.did_change_points)

    def handle_file_opened(self, file_path: str):
        """Handle the opening of a JSON file path."""

        # load json data from file
        with open(file_path, "r", encoding="utf-8") as file:
            quickdraw_data = json.load(file)

        # update unlabelled list view model
        self.model.update_data(quickdraw_data)
        self.view.update_lists(self.model.unlabelled_list_model, self.model.labelled_list_model)

    def handle_export_initiated(self):
        """Handle the initiation of the export process."""
        # First check if there are any labelled instances to export
        if self.model.labelled_list_model.rowCount() == 0:
            return

        # Prepare the JSON data
        data = []
        for i in range(self.model.labelled_list_model.rowCount()):
            instance = self.model.labelled_list_model.data(
                self.model.labelled_list_model.index(i, 0)
            )
            data.append(
                {
                    "label": instance.label,
                    "key": instance.key,
                    "drawing": instance.drawing,
                    "points": instance.points,
                }
            )

        # Show the file dialog
        file_dialog = QFileDialog()
        selected_file_path, _ = file_dialog.getSaveFileName(
            self.view,
            "Save File",
            "",
            "JSON (*.json)",
        )

        # Export the data
        if selected_file_path:
            with open(selected_file_path, "w", encoding="utf-8") as file:
                json.dump(data, file, ensure_ascii=False, indent=4)

    def did_click_unlabelled_list(self, index):
        self.view.labelled_list_view.selectionModel().clearSelection()
        self.model.update_selected_instance(index, labelled=False)
        self.view.update_selected_instance(self.model.selected_instance)

    def did_click_labelled_list(self, index):
        self.view.unlabelled_list_view.selectionModel().clearSelection()
        self.model.update_selected_instance(index, labelled=True)
        self.view.update_selected_instance(self.model.selected_instance)

    def did_change_points(self, points):
        # Update the points if this is a labelled instance
        if isinstance(self.model.selected_instance, LabelledInstance):
            self.model.selected_instance.points = points

        # Update points label view
        if len(points) > 0:
            text = "Points (x, y):\n"
            for i, point in enumerate(points):
                text += f"\t{i+1}: ({point[0]}, {point[1]})\n"
            self.view.points_label_view.setPlainText(text)
        else:
            self.view.points_label_view.setPlainText(
                "Click on the drawing to add or remove points for labelling."
            )

        # Update availability of add to labelled button
        self.view.selected_instance_button.setEnabled(
            len(points) > 0 and not isinstance(self.model.selected_instance, LabelledInstance)
        )

    def did_click_add_to_labelled(self):
        """Handle click on the add to labelled button.

        Note:
            - Get the points from the selected instance view
            - Create a new labelled instance with the points
            - Add the new instance to the labelled list model
            - Remove the instance from the unlabelled list model
            - Select the next instance in the unlabelled list model
        """
        points = self.view.selected_instance_view.points
        instance = LabelledInstance(**self.model.selected_instance.__dict__, points=points)
        self.model.labelled_list_model.add_instance(instance)
        self.model.unlabelled_list_model.remove_instance(self.model.selected_instance)
        self.view.update_lists(self.model.unlabelled_list_model, self.model.labelled_list_model)

        # If there are more unlabelled instances
        if self.model.unlabelled_list_model.rowCount() > 0:
            cur_index = self.view.unlabelled_list_view.currentIndex()
            # bump cur_index to the next instance if it's not the last one
            if cur_index.row() < self.model.unlabelled_list_model.rowCount() - 1:
                pass  # do nothing
            else:
                # select the first instance if it's the last one
                self.view.unlabelled_list_view.setCurrentIndex(
                    self.model.unlabelled_list_model.index(0, 0)
                )

            self.model.update_selected_instance(self.view.unlabelled_list_view.currentIndex())
            self.view.update_selected_instance(self.model.selected_instance)
