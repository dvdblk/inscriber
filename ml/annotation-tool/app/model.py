from dataclasses import dataclass

from PyQt6.QtCore import QAbstractListModel, Qt


@dataclass
class QuickDrawInstance:
    """Intermediate representation of a Quick, Draw! instance."""

    label: str
    """Label of the instance."""
    key: str
    """Unique key for the instance."""
    drawing: list
    """List of strokes, where each stroke is a list of points."""


@dataclass
class LabelledInstance(QuickDrawInstance):
    points: list
    """List of points, where each point is a tuple of (x, y)."""


class Model:
    """Main model of the application."""

    def __init__(self):
        self.unlabelled_list_model = None
        self.labelled_list_model = None

        self.selected_instance = None

    def update_data(self, quickdraw_data):
        """Update the data with new quickdraw data.

        Note: Should be called when new dataset is loaded.
        """
        unlabelled_data = []
        for instance in quickdraw_data:
            label = instance["word"]
            key = instance["key_id"]
            drawing = instance["drawing"]
            ir_instance = QuickDrawInstance(label, key, drawing)
            unlabelled_data.append(ir_instance)

        self.unlabelled_list_model = UnlabelledListModel(unlabelled_data)
        self.labelled_list_model = LabelledListModel([])

    def update_selected_instance(self, index, labelled=False):
        if labelled:
            instance = self.labelled_list_model.data(index, None)
        else:
            instance = self.unlabelled_list_model.data(index, None)

        self.selected_instance = instance


class BaseListModel(QAbstractListModel):
    """Base class for list models."""

    def __init__(self, data, parent=None):
        super().__init__(parent)
        self._data = data

    def data(self, index, role=None):
        if role == Qt.ItemDataRole.DisplayRole:
            return self._data[index.row()]
        elif role is None:
            return self._data[index.row()]

    def rowCount(self, index=None):
        return len(self._data)

    def add_instance(self, instance):
        """Add a new instance to the model."""
        self._data.append(instance)
        self.layoutChanged.emit()

    def remove_instance(self, instance):
        """Remove an instance from the model."""
        if instance in self._data:
            self._data.remove(instance)
            self.layoutChanged.emit()


class UnlabelledListModel(BaseListModel):
    """Model for the list view of unlabelled instances."""

    def data(self, index, role=None):
        if role == Qt.ItemDataRole.DisplayRole:
            instance = self._data[index.row()]
            return f"{instance.label} ({instance.key[:16]}...)"
        else:
            return super().data(index, role)


class LabelledListModel(BaseListModel):
    """Model for the list view of labelled instances."""

    def data(self, index, role=None):
        if role == Qt.ItemDataRole.DisplayRole:
            instance = self._data[index.row()]
            return f"{instance.label} ({len(instance.points)} pts, {instance.key[:16]}...))"
        else:
            return super().data(index, role)
