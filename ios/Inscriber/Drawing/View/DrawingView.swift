//
//  DrawingView.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI

struct DrawingView: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject private var undoRedoObserver = UndoRedoObserver()
    
    var body: some View {
        VStack {
            PKCanvasRepresentation(
                canUndo: $undoRedoObserver.canUndo,
                canRedo: $undoRedoObserver.canRedo
            )
        }
        .onAppear {
            undoRedoObserver.undoManager = undoManager
        }
        .onChange(of: undoManager) { newManager in
            // UndoManager can change during the lifecycle so we need to keep it updated in the observer
            undoRedoObserver.undoManager = newManager
        }
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button {
                    undoManager?.undo()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward.circle")
                }
                .disabled(!undoRedoObserver.canUndo)
                Button {
                    undoManager?.redo()
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward.circle")
                }
                .disabled(!undoRedoObserver.canRedo)
            }
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DrawingView()
        }
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad")
        
        NavigationStack {
            DrawingView()
        }
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone")
    }
}