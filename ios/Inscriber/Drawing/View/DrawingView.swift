//
//  DrawingView.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI

struct DrawingView: View {
    @Environment(\.undoManager) var undoManager
    @StateObject private var undoRedoObserver = UndoRedoObserver()
    @StateObject private var predictionModel = MLModel()
    
    var body: some View {
        VStack {
            PKCanvasRepresentation(
                canUndo: $undoRedoObserver.canUndo,
                canRedo: $undoRedoObserver.canRedo
            ) { drawing in
                // 1. Predict
                //predictionModel.predict()
                
                // 2. Update drawing based on prediction
            }
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
            ToolbarItem(placement: .principal) {
                Text("Inscriber")
                    .font(.custom("Noteworthy", size: 24, relativeTo: .headline).weight(.semibold))
            }
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Picker("Prediction Model", selection: $predictionModel.modelType) {
                        ForEach(MLModel.ModelType.allCases) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    .pickerStyle(.inline)
                } label: {
                    Label("Settings", systemImage: "brain")
                }
            }
        }
        .tint(.pink)
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
