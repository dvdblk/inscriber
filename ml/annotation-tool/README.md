# OHWR Dataset Annotation Tool

Turns a GoogleQuickDraw style dataset into a labelled dataset ready for training an Inscriber-style model. Annotates the sequences of strokes with:

* label of the object drawn (e.g. 'circle', 'square', 'triangle', 'heart')
* a set of 2D points that represent the geometric shape of this instance


<img src="annotation-tool-preview.png" width="40%" height="40%">

## Quick Start

```
pip install -r requirements.txt
python -m app.main
```

## Credits
While creating this I went over the tutorial on [https://www.pythonguis.com/pyqt6/](https://www.pythonguis.com/pyqt6/). Thanks [Martin](https://www.pythonguis.com/contact/)!
