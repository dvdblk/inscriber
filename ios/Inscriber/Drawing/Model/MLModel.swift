//
//  MLModel.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation

class MLModel: ObservableObject {
    
    /// Type of the MLModel currently used in the app
    enum ModelType: String, CaseIterable, Identifiable {
        case turicreateBaseline = "Turicreate (Baseline)"
        case turicreateCustom = "Turicreate (Custom)"
        case other = "Other"
        
        var id: ModelType { self }
    }
    
    @Published var modelType: ModelType = .turicreateBaseline

    func predict(completion: @escaping ((Prediction) -> Void)) {
        switch modelType {
        case .turicreateBaseline:
            break
        default:
            break
        }
        
        // FIXME: Use CoreML
        let randomShape = RecognizedShape.allCases.randomElement()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(Prediction(confidence: 1, recognizedShape: randomShape))
        }
    }
}
