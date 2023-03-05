//
//  CustomCanvasView.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import UIKit
import PencilKit

class CustomCanvasView: PKCanvasView {
    
    /// Action that's called whenever a touch move significantly
    var onTouchesMoved: (() -> Void)?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        // Only call the action on touches that move at least 0.5 pts
        let distance = hypot((previousLocation.x - location.x), (previousLocation.y - location.y))
        if distance >= 0.5 {
            onTouchesMoved?()
        }
    }
}
