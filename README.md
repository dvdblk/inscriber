# Inscriber 🖋️

Online on-device handwritten shape recognition.

The app performs shape recognition based on the *current* stroke in progress. Whenever the model detects a known shape a preview of it is shown to the user (mimics the official Notes app).

## Features
* Recognize primitive shapes (such as 🔺, 🟥, 🔴, ...)
* Multiple models to choose from
* Supports handwriting with a finger or Apple Pencil
* Optimized for iOS & iPadOS 16.0+

## Models
Can be found in the `ml/` directory. To export the pytorch model to CoreML see `models/export.md`.