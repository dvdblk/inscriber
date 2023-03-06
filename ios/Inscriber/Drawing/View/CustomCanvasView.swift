//
//  CustomCanvasView.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import UIKit
import PencilKit

/// A custom `PKCanvasView` that tracks the currently drawn (active) stroke as a PKStroke before the user lifts the pencil
/// Inspired by the StrokeGestureRecognizer https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/leveraging_touch_input_for_drawing_apps
/// Most notable differences are that CustomCanvasView honors the superclass implementation of all touch handling methods and the use of PencilKit structures and classes (e.g. `PKStroke`, `PKStrokePoint`).
class CustomCanvasView: PKCanvasView {
    
    // MARK: - Data
    var inkingTool: PKInkingTool? {
        return tool as? PKInkingTool
    }
    
    // MARK: - State
    var activeStrokeContext: ActiveStrokeContext? { didSet { activeStrokeContextChangedAction?(activeStrokeContext) } }
    
    // MARK: - Callback
    var activeStrokeContextChangedAction: ((ActiveStrokeContext?) -> Void)?
    
    // MARK: - Touch handling methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if activeStrokeContext == nil, let touch = touches.first, let inkingTool = inkingTool {
            let newActiveStrokeContext = ActiveStrokeContext(tool: inkingTool, initialTouch: touch)
            newActiveStrokeContext.append(touches: touches, view: self, event: event)
            activeStrokeContext = newActiveStrokeContext
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        activeStrokeContext?.append(touches: touches, view: self, event: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let context = activeStrokeContext, context.append(touches: touches, view: self, event: event) {
            resetStroke()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if let context = activeStrokeContext, context.append(touches: touches, view: self, event: event) {
            resetStroke()
        }
    }
    
    func resetStroke() {
        activeStrokeContext = nil
    }
}
