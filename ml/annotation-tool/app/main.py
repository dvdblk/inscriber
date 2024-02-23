import sys

from PyQt6.QtWidgets import QApplication

from app.windows import MainWindow


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    sys.exit(app.exec())
