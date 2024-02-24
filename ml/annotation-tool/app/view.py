from app.model import LabelledInstance, QuickDrawInstance
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QBrush, QColor, QPainter, QPalette, QPen
from PyQt6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QListView,
    QPushButton,
    QTextEdit,
    QVBoxLayout,
    QWidget,
)


class SelectedInstanceView(QWidget):
    """
    View for drawing the selected instance.
    """

    CIRCLE_RADIUS = 12
    """The radius of the circles representing the points."""

    points_changed = pyqtSignal(list)

    def __init__(self):
        super().__init__()

        self.setFixedSize(512, 512)

        self.drawing_data = None
        self.points = []

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.fillRect(self.rect(), QColor(Qt.GlobalColor.white))

        pen = QPen()
        painter.setPen(pen)

        self._draw_strokes(painter)
        self._draw_points(painter)

    def _draw_strokes(self, painter):
        if self.drawing_data is not None:
            for stroke in self.drawing_data:
                for i in range(1, len(stroke[0])):
                    # Draw line segments
                    painter.drawLine(stroke[0][i - 1], stroke[1][i - 1], stroke[0][i], stroke[1][i])

    def _draw_points(self, painter):
        circle_pen = QPen(QColor(255, 0, 0), 2)  # Red pen with a width of 2
        painter.setPen(circle_pen)

        radius = self.CIRCLE_RADIUS
        for number, circle in enumerate(self.points):
            x, y = circle
            # Set the brush for filling the circle
            circle_brush = QBrush(QColor(255, 0, 0))  # Fully red fill
            painter.setBrush(circle_brush)

            painter.drawEllipse(x - radius, y - radius, 2 * radius, 2 * radius)

            # Set the text color to white
            text_pen = QPen(QColor(255, 255, 255))
            painter.setPen(text_pen)
            painter.drawText(x - 5, y + 5, str(number + 1))

    def update_drawing(self, drawing, points=None):
        self.drawing_data = drawing
        self.points = points or []
        self.points_changed.emit(self.points)

        self.update()

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton and self.drawing_data is not None:
            # Add a circle on left-click
            self.add_circle(event.pos())

        elif event.button() == Qt.MouseButton.RightButton:
            # Remove a circle on right-click
            self.remove_circle(event.pos())

    def add_circle(self, pos):
        # Add the circle information to the list
        self.points.append((pos.x(), pos.y()))

        # Emit the points changed signal
        self.points_changed.emit(self.points)

        # Trigger a redraw
        self.update()

    def remove_circle(self, pos):
        # Find and remove the circle that contains the right-clicked position
        radius = self.CIRCLE_RADIUS
        for circle in self.points:
            x, y = circle
            distance = ((pos.x() - x) ** 2 + (pos.y() - y) ** 2) ** 0.5
            if distance <= radius:
                self.points.remove(circle)
                self.points_changed.emit(self.points)
                self.update()
                break


class MainView(QWidget):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

        main_horizontal_layout = QHBoxLayout()

        unlabelled_vbox_layout = QVBoxLayout()
        unlabelled_vbox_layout.addWidget(QLabel("Unlabelled instances"))
        unlabelled_list_view = QListView()
        unlabelled_list_view.setMaximumWidth(256)
        unlabelled_vbox_layout.addWidget(unlabelled_list_view)
        self.unlabelled_list_view = unlabelled_list_view

        label_vertical_layout = QVBoxLayout()
        self.selected_instance_view = SelectedInstanceView()
        selected_instance_label = QLabel("Selected instance")
        self.selected_instance_button = QPushButton("Add to labelled")
        self.selected_instance_button.setEnabled(False)
        self.selected_instance_button.setMaximumWidth(256)
        points_label_view = QTextEdit()
        points_label_view.setReadOnly(True)
        points_label_view.setPlainText(
            "Click on the drawing to add or remove points for labelling."
        )
        points_label_view.setCursorWidth(0)
        self.points_label_view = points_label_view

        label_vertical_widgets = [
            selected_instance_label,
            self.selected_instance_view,
            points_label_view,
            self.selected_instance_button,
        ]
        # Remove background and border
        palette = QPalette()
        palette.setColor(
            QPalette.ColorRole.Window, QColor(0, 0, 0, 0)
        )  # Set background color to transparent
        palette.setColor(
            QPalette.ColorRole.Base, QColor(0, 0, 0, 0)
        )  # Set base color to transparent
        points_label_view.setPalette(palette)
        points_label_view.setStyleSheet("border: 0; background: transparent;")

        for widget in label_vertical_widgets:
            # widget.setMaximumWidth(256)
            label_vertical_layout.addWidget(widget)
        label_vertical_layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        label_vertical_layout.setAlignment(
            self.selected_instance_view, Qt.AlignmentFlag.AlignCenter
        )
        label_vertical_layout.setAlignment(selected_instance_label, Qt.AlignmentFlag.AlignCenter)
        label_vertical_layout.setAlignment(
            self.selected_instance_button, Qt.AlignmentFlag.AlignCenter
        )

        labelled_vbox_layout = QVBoxLayout()
        labelled_vbox_layout.addWidget(QLabel("Labelled instances"))
        labelled_list_view = QListView()
        labelled_list_view.setMaximumWidth(256)
        labelled_vbox_layout.addWidget(labelled_list_view)
        self.labelled_list_view = labelled_list_view

        main_horizontal_layout.addLayout(unlabelled_vbox_layout)
        main_horizontal_layout.addLayout(label_vertical_layout)
        main_horizontal_layout.addLayout(labelled_vbox_layout)

        self.setLayout(main_horizontal_layout)

    def update_lists(self, unlabelled_data_model, labelled_data_model):
        self.unlabelled_list_view.setModel(unlabelled_data_model)
        self.labelled_list_view.setModel(labelled_data_model)

    def update_selected_instance(self, instance):
        """Update the selected instance view."""
        if isinstance(instance, LabelledInstance):
            self.selected_instance_view.update_drawing(instance.drawing, points=instance.points)
        elif isinstance(instance, QuickDrawInstance):
            self.selected_instance_view.update_drawing(instance.drawing)
