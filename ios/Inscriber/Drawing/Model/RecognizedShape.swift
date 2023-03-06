//
//  RecognizedShape.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation
import PencilKit

/// The types of shapes that the models are able to predict
enum RecognizedShape: String, Equatable, CaseIterable {
    case square
    case rectangle
    case circle
    case ellipse
    case line
    case triangle
    
    /// TODO: arc, heart, speech bubble, star, pentagon
}

// MARK: - Drawing
extension RecognizedShape {
    func toStroke(from stroke: PKStroke) -> PKStroke {
        switch self {
        case .square:
            return stroke
        default:
            return PKStroke(ink: stroke.ink, path: stroke.path, transform: CGAffineTransform.init(rotationAngle: 45))
        }
    }
}
