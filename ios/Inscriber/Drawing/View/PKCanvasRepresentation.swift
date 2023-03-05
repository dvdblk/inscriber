//
//  PKCanvasRepresentation.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    let canvasView = CustomCanvasView()
    let toolPicker = PKToolPicker()
    let strokeChangedAction: ((PKDrawing) -> Void)
    
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    
    init(canUndo: Binding<Bool>, canRedo: Binding<Bool>, strokeChangedAction: @escaping ((PKDrawing) -> Void)) {
        self._canUndo = canUndo
        self._canRedo = canRedo
        self.strokeChangedAction = strokeChangedAction
    }
    
    func makeUIView(context: Context) -> some UIView {
        canvasView.delegate = context.coordinator
        canvasView.onTouchesMoved = {
            strokeChangedAction(canvasView.drawing)

            //print(canvasView.)
            // FIXME: collect PKStroke in canvasView touchesMoved
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
        
        func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
            print("canvasViewDidFinishRendering")
        }
    }
}
