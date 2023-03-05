import turicreate as tc
import numpy as np
import os
import json

random_state = np.random.RandomState(100)

# Change if applicable
quickdraw_dir = 'quickdraw'
strokes_dir = os.path.join(quickdraw_dir, 'strokes')
sframes_dir = os.path.join(quickdraw_dir, 'sframes')
ndjson_ext = '.ndjson'
num_examples_per_class = 100
classes = ["square", "triangle"]
num_classes = len(classes)

def build_strokes_sframe():
    drawings_list, labels_list = [], []
    for class_name in classes:
        with open(os.path.join(strokes_dir, class_name+ndjson_ext)) as fin:
            ndjson_data = list(map(lambda x: x.strip(), fin.readlines()))
        random_state.shuffle(ndjson_data)
        ndjson_data_selected = list(map(json.loads, ndjson_data[:num_examples_per_class]))
        raw_drawing_list = [ndjson["drawing"] for ndjson in ndjson_data_selected]
        def raw_to_final(raw_drawing):
            return [
                [
                    {
                        "x": raw_drawing[stroke_id][0][i], 
                        "y": raw_drawing[stroke_id][1][i]
                    } for i in range(len(raw_drawing[stroke_id][0]))
                ] 
                for stroke_id in range(len(raw_drawing))
            ]

        final_drawing_list = list(map(raw_to_final, raw_drawing_list))
        drawings_list.extend(final_drawing_list)
        labels_list.extend([class_name] * num_examples_per_class)
    sf = tc.SFrame({"drawing": drawings_list, "label": labels_list})
    sf.save(os.path.join(sframes_dir, "stroke_square_triangle.sframe"))
    return sf 

sf = build_strokes_sframe()