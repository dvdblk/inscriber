//
//  RecognizedShape.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation

/// The types of shapes that the models are able to predict
enum RecognizedShape: CaseIterable {
    case square
    case rectangle
    case circle
    case ellipse
    case line
    case triangle
    
    /// TODO: arc, heart, speech bubble, star, pentagon
}
