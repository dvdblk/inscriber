//
//  PredictionManager.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation
import PencilKit
import CoreML
import Vision

var lastCgImage: CGImage?


class PredictionManager: ObservableObject {
    
    /// Type of the MLModel currently used in the app
    enum ModelType: String, CaseIterable, Identifiable {
        case turicreateBaseline = "Turicreate (Baseline)"
        case turicreateCustom = "Turicreate (Custom)"
        case other = "Other"
        
        var id: ModelType { self }
    }
        
    /// Currently selected model to use for handwritten shape recognition
    @Published var modelType: ModelType = .turicreateBaseline
    
    private let turicreateBaselineModel = try! VNCoreMLModel(for: MySquareTriangleClassifier(configuration: MLModelConfiguration()).model)

    func predict(stroke: PKStroke, completion: @escaping ((Prediction) -> Void)) {
        
        switch modelType {
        case .turicreateBaseline:
            let request = VNCoreMLRequest(model: turicreateBaselineModel, completionHandler: { [] request, error in
                if let sortedResults = request.results! as? [VNClassificationObservation] {
                    print("Results")
                    for result in sortedResults {
                        print(result.identifier, result.confidence)
                    }
                    print("------------------------------")
                }
            })
            
            DispatchQueue.global(qos: .userInitiated).async {
                let mainImage: CGImage = stroke.toDrawing.rasterized()
                lastCgImage = mainImage
                let handler = VNImageRequestHandler(cgImage: mainImage)
                
                try? handler.perform([request])
            }
        default:
            break
        }
    }
}
