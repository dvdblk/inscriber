//
//  DrawingView.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI

struct DrawingView: View {
    @Environment(\.undoManager) var undoManager
    @State private var showingOptionsPopover = false
    @State private var drawWithTouch = !UIDevice.interfaceIsPad
    @State private var penWidth = PenWidth.normal
    @State private var activeStrokeState = ActiveStrokeState.drawing
    @StateObject private var undoRedoObserver = UndoRedoObserver()
    @StateObject private var predictionManager = PredictionManager()
    
    var body: some View {
        VStack {
            PKCanvasRepresentation(
                canUndo: $undoRedoObserver.canUndo,
                canRedo: $undoRedoObserver.canRedo,
                drawWithTouch: $drawWithTouch,
                penWidth: $penWidth,
                activeStrokeState: $activeStrokeState
            )
        }
        .onAppear {
            undoRedoObserver.undoManager = undoManager
        }
        .onChange(of: undoManager) { newManager in
            // UndoManager can change during the lifecycle so we need to keep it updated in the observer
            undoRedoObserver.undoManager = newManager
        }
        .onChange(of: activeStrokeState) { newState in
            switch newState {
            case .drawing:
                print("drawing")
            case .awaitingPrediction(let stroke):
                predictionManager.predict(stroke: stroke) { result in
                    if self.activeStrokeState == .awaitingPrediction(stroke: stroke) {
                        self.activeStrokeState = .predictedShape(prediction: result, forStroke: stroke)
                    }
                }
            case .predictedShape(let prediction, let stroke):
                print("Predicted \(prediction.recognizedShape) with confidence \(prediction.confidence) for last stroke.")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: UIDevice.interfaceIsPad ? .cancellationAction : .bottomBar) {
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
                Spacer()
                    .frame(minWidth: 16)
                Button {
                    showingOptionsPopover = true
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
                .popover(isPresented: $showingOptionsPopover) {
                    List {
                        if UIDevice.interfaceIsPad {
                            HStack(spacing: 8) {
                                Text("Draw with Touch")
                                Spacer()
                                Toggle("", isOn: $drawWithTouch)
                                    .labelsHidden()
                            }
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pen Width")
                            
                            Picker("Pen Width", selection: $penWidth) {
                                ForEach(PenWidth.allCases) { width in
                                    Text("\(width.rawValue)")
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        Section(header: Text("App")) {
                            Text("Version")
                                .badge(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                        }
                    }
                    .scrollDisabled(true)
                    .frame(minWidth: 280, minHeight: 280)
                }
                .presentationDetents([.medium, .large])
            }
            ToolbarItem(placement: .principal) {
                Text("Inscriber")
                    .font(.custom("Noteworthy", size: 24, relativeTo: .headline).weight(.semibold))
            }
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Picker("Prediction Model", selection: $predictionManager.modelType) {
                        ForEach(PredictionManager.ModelType.allCases) { model in
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
                .navigationBarTitleDisplayMode(.inline)
        }
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad")
        
        NavigationStack {
            DrawingView()
                .navigationBarTitleDisplayMode(.inline)
        }
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone")
            
    }
}
