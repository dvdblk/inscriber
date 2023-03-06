//
//  PKCanvasRepresentation.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI
import PencilKit

enum ActiveStrokeState: Equatable {
    /// Default state for the active stroke. Doesn't necessarily mean the user is actively drawing.
    case drawing
    /// Whenever the user pauses drawing without lifting finger / pencil and awaits a prediction for his current `stroke`
    case awaitingPrediction(stroke: PKStroke)
    /// When the ML model predicts a shape for a given stroke.
    case predictedShape(prediction: Prediction, forStroke: PKStroke)
}

extension PKStroke: Equatable {
    public static func == (lhs: PKStroke, rhs: PKStroke) -> Bool {
        return true
    }
}

struct PKCanvasRepresentation: UIViewRepresentable {
    
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    @Binding var drawWithTouch: Bool
    @Binding var penWidth: PenWidth
    @Binding var activeStrokeState: ActiveStrokeState
    
    init(canUndo: Binding<Bool>, canRedo: Binding<Bool>, drawWithTouch: Binding<Bool>, penWidth: Binding<PenWidth>, activeStrokeState: Binding<ActiveStrokeState>) {
        self._canUndo = canUndo
        self._canRedo = canRedo
        self._drawWithTouch = drawWithTouch
        self._penWidth = penWidth
        self._activeStrokeState = activeStrokeState
    }
    
    func makeDefaultTool(width: PenWidth) -> PKInkingTool {
        return PKInkingTool(.pen, color: PKInkingTool.convertColor(.white, from: .light, to: .dark), width: CGFloat(width.rawValue))
    }
    
    func makeUIView(context: Context) -> CustomCanvasView {
        let canvasView = CustomCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = drawWithTouch ? .anyInput : .pencilOnly
        canvasView.tool = makeDefaultTool(width: penWidth)
        canvasView.activeStrokeContextChangedAction = { strokeContext in
            // If a new stroke drawing context has been created prepare the actions
            if let strokeContext = strokeContext {
                strokeContext.strokeFinishingAction = { finishingStroke in
                    // On finishing, attempt to make a prediction
                    self.activeStrokeState = .awaitingPrediction(stroke: finishingStroke)
                }
                strokeContext.strokeContinueDrawingAction = {
                    // On continue drawing.. continue drawing
                    self.activeStrokeState = .drawing
                }
            } else {
                // On stroke context deinit, continue drawing (default state)
                self.activeStrokeState = .drawing
            }
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
            lastCgImage
        }
    }
}
