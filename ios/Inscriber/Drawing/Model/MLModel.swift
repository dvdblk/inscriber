//
//  MLModel.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation

/// Type of the MLModel currently used in the app
enum MLModel: String, CaseIterable, Identifiable {
    case turicreateBaseline = "Baseline Turicreate"
    case other = "Other"
    
    var id: MLModel { self }
}
