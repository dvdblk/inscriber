//
//  PKCanvasRepresentation.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    let strokeChangedAction: ((PKDrawing) -> Void)
    
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    @Binding var drawWithTouch: Bool
    @Binding var penWidth: PenWidth
    
    init(canUndo: Binding<Bool>, canRedo: Binding<Bool>, drawWithTouch: Binding<Bool>, penWidth: Binding<PenWidth>, strokeChangedAction: @escaping ((PKDrawing) -> Void)) {
        self._canUndo = canUndo
        self._canRedo = canRedo
        self._drawWithTouch = drawWithTouch
        self._penWidth = penWidth
        self.strokeChangedAction = strokeChangedAction
    }
    
    func makeDefaultTool(width: PenWidth) -> PKInkingTool {
        return PKInkingTool(.pen, color: PKInkingTool.convertColor(.white, from: .light, to: .dark), width: CGFloat(width.rawValue))
    }
    
    func makeUIView(context: Context) -> CustomCanvasView {
        let canvasView = CustomCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = drawWithTouch ? .anyInput : .pencilOnly
        canvasView.tool = makeDefaultTool(width: penWidth)
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
    
    func updateUIView(_ uiView: CustomCanvasView, context: Context) {
        uiView.drawingPolicy = drawWithTouch ? .anyInput : .pencilOnly
        uiView.tool = makeDefaultTool(width: penWidth)
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
    }
}
