# Inscriber ML Models

All ML models use strokes as raw data. Some models might do preprocessing that transforms these strokes into bitmaps.

## Dataset generation

## Turicreate model (simple CNN)
> Requires Python 3.8 and [turicreate](https://github.com/apple/turicreate)

### Data
Input to the turicreate model is a 28x28 bitmap however we are using strokes as raw data. Preprocessing of strokes (`[PKStrokePath]`) into images can be found [here](https://apple.github.io/turicreate/docs/userguide/drawing_classifier/export-coreml.html).

To download the raw stroke data from [Google Quickdraw](https://quickdraw.withgoogle.com/data) run
```
$ sh download_data.sh
...
$ tree -L 2 quickdraw
quickdraw
├── sframes
└── strokes
    ├── square.ndjson
    └── triangle.ndjson
```

After this you can add your own custom shapes datasets.

#### Constructing SFrame
After all different classes of strokes are present in `quickdraw/strokes` you can run
```
$ python build_strokes_sframe.py
```

To create the sframe for model training.