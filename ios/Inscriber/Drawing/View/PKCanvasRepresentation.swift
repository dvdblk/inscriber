//
//  PKCanvasRepresentation.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI
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

struct PKCanvasRepresentation: UIViewRepresentable {
    let canvasView = CustomCanvasView()
    let toolPicker = PKToolPicker()
    
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    
    init(canUndo: Binding<Bool>, canRedo: Binding<Bool>) {
        self._canUndo = canUndo
        self._canRedo = canRedo
    }
    
    func makeUIView(context: Context) -> some UIView {
        canvasView.delegate = context.coordinator
        canvasView.onTouchesMoved = {
            
        }
        return canvasView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: uiView)
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentation
        var prevStrokesCount = 0
        
        init(_ parent: PKCanvasRepresentation) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Update undo / redo buttons after every drawing change
            if let undoManager = canvasView.undoManager {
                let strokes = canvasView.drawing.strokes
                parent.canUndo = undoManager.canUndo && !strokes.isEmpty
                parent.canRedo = undoManager.canRedo
            }
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            
        }
    }
}
