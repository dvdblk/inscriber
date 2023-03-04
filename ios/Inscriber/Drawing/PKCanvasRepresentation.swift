//
//  PKCanvasRepresentation.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    let canvasView = PKCanvasView()
    let toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> some UIView {
        canvasView.delegate = context.coordinator
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
        
        init(_ parent: PKCanvasRepresentation) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            print("canvasViewDrawingDidChange")
        }
    }
}
