import sys

from app.controller import MainContoller, MenuController
from app.view import MainView
from app.window import MainWindow
from PyQt6.QtWidgets import QApplication

if __name__ == "__main__":
    app = QApplication(sys.argv)

    window = MainWindow()
    menu_controller = MenuController(window, app)

    # model = Model()
    view = MainView()
    controller = MainContoller(None, view, menu_controller=menu_controller)

    window.setCentralWidget(view)

    sys.exit(app.exec())
