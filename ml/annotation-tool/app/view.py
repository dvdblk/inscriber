from PyQt6.QtCore import Qt
from PyQt6.QtGui import QColor, QPainter, QPen
from PyQt6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListView,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class DrawWidget(QWidget):
    def __init__(self):
        super().__init__()

        self.setFixedSize(256, 256)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.fillRect(self.rect(), QColor(Qt.GlobalColor.white))

        pen = QPen()
        painter.setPen(pen)

        # Example: draw a rectangle
        # painter.drawRect(10, 10, 100, 100)

        # Add your drawing logic here using QPainter methods


class MainView(QWidget):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

        main_horizontal_layout = QHBoxLayout()

        unlabelled_vbox_layout = QVBoxLayout()
        unlabelled_vbox_layout.addWidget(QLabel("Unlabelled instances"))
        unlabelled_list_view = QListView()
        unlabelled_list_view.setMaximumWidth(256)
        unlabelled_vbox_layout.addWidget(unlabelled_list_view)

        label_vertical_layout = QVBoxLayout()
        draw_widget = DrawWidget()
        label_vertical_layout.addWidget(draw_widget)
        label_vertical_widgets = [
            QLabel("Selected instance label:"),
            QLineEdit(),
            QPushButton("Add instance label"),
        ]
        for widget in label_vertical_widgets:
            widget.setMaximumWidth(256)
            label_vertical_layout.addWidget(widget)
        label_vertical_layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        label_vertical_layout.setAlignment(draw_widget, Qt.AlignmentFlag.AlignCenter)
        label_vertical_layout.setContentsMargins(0, 24, 0, 0)

        labelled_vbox_layout = QVBoxLayout()
        labelled_vbox_layout.addWidget(QLabel("Labelled instances"))
        labelled_list_view = QListView()
        labelled_list_view.setMaximumWidth(256)
        labelled_vbox_layout.addWidget(labelled_list_view)

        main_horizontal_layout.addLayout(unlabelled_vbox_layout)
        main_horizontal_layout.addLayout(label_vertical_layout)
        main_horizontal_layout.addLayout(labelled_vbox_layout)

        self.setLayout(main_horizontal_layout)
