#!/bin/sh

# Make directories with the data
mkdir -p {quickdraw/strokes,quickdraw/sframes}

# Stroke data (around 200 MB each)
curl https://storage.googleapis.com/quickdraw_dataset/full/raw/square.ndjson > quickdraw/strokes/square.ndjson
curl https://storage.googleapis.com/quickdraw_dataset/full/raw/triangle.ndjson > quickdraw/strokes/triangle.ndjson
