//
//  Prediction.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation

/// Describes a prediction from the ML Model
struct Prediction: Equatable {
    let confidence: Float
    let recognizedShape: RecognizedShape?
}
