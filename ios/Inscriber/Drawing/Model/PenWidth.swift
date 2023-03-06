//
//  PenWidth.swift
//  Inscriber
//
//  Created by David Bielik on 06/03/2023.
//

import Foundation

enum PenWidth: Int, CaseIterable, Identifiable {
    case thin = 4
    case normal = 10
    case thick = 16
    
    var id: PenWidth { self }
}
