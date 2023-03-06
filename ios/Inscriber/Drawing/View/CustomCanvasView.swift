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
    /// The current stroke in progress
    var stroke: PKStroke {
        let ink = inkingTool?.ink ?? PKInk(.pen, color: UIColor.label)
        let path = PKStrokePath(
            controlPoints: strokePoints,
            creationDate: Date()
        )
        return PKStroke(ink: ink, path: path)
    }
    var inkingTool: PKInkingTool? {
        return tool as? PKInkingTool
    }

    var strokePoints = [PKStrokePoint]()
    
    // MARK: - State
    var trackedTouch: UITouch?
    var initialTimestamp: TimeInterval?
    
    // MARK: - Callback
    /// Action that's called whenever a touch move significantly
    var onTouchesMoved: (() -> Void)?
    
    // MARK: - Stroke Data Collection
    /// Appends touch data to the stroke sample.
    /// - Tag: appendTouches
    /// - Returns: `true` if touches were appended, `false` otherwise
    @discardableResult
    func append(touches: Set<UITouch>, event: UIEvent?) -> Bool {
        // Check that we have a touch to append, and that touches
        // doesn't contain it.
        guard let touchToAppend = trackedTouch, touches.contains(touchToAppend) == true
        else { return false }
        
        // Collect coalesced touches
        if let event = event {
            let coalescedTouches = event.coalescedTouches(for: touchToAppend)!
            let lastIndex = coalescedTouches.count - 1
            for index in 0..<lastIndex {
                saveStrokePoint(touch: coalescedTouches[index], coalesced: true)
            }
            saveStrokePoint(touch: coalescedTouches[lastIndex], coalesced: false)
        }
        
        return true
    }
    
    func saveStrokePoint(touch: UITouch, coalesced: Bool) {
        // Only collect samples that actually moved in 2D space.
        let location = touch.preciseLocation(in: self)
        if let previousSample = strokePoints.last {
            if (previousSample.location - location).quadrance < 0.05 {
                return
            }
        }
        guard let initialTimestamp = initialTimestamp, let inkingTool = inkingTool else { return }
        
        // 45 degrees
        var azimuth: CGFloat = 45 * .pi / 180
        var altitutde: CGFloat = 45 * .pi / 180
        if touch.type == .pencil {
            azimuth = touch.azimuthAngle(in: self)
            altitutde = touch.altitudeAngle
        }
        
        // strokePoint opacity and width are dependent on the PKTool, unfortunately this api is private
        let strokePoint = PKStrokePoint(
            location: location,
            timeOffset: touch.timestamp - initialTimestamp,
            size: CGSize(width: inkingTool.width, height: inkingTool.width),
            opacity: inkingTool.color.cgColor.alpha,
            force: touch.force,
            azimuth: azimuth,
            altitude: altitutde
        )

        if touch.type == .pencil {
            let estimatedProperties = touch.estimatedProperties
            
            // If estimated properties contains .azimuth, we need to update it
            // in the next pass of estimated properties that doesn't contain .azimuth
            if strokePoints.isEmpty && estimatedProperties.contains(.azimuth) {
                // TODO: expectsAltitudeAzimuthBackfill
            }
        }
        
        strokePoints.append(strokePoint)
    }
    
    func resetStroke() {
        trackedTouch = nil
        strokePoints = []
    }
    
    // MARK: - Touch handling methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if trackedTouch == nil, let touch = touches.first {
            trackedTouch = touch
            initialTimestamp = touch.timestamp
        }
        
        append(touches: touches, event: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        append(touches: touches, event: event)
        
        guard let touch = touches.first else { return }
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)

        // Only call the action on touches that move at least 0.5 pts
        if previousLocation.distance(to: location) >= 0.5 {
            onTouchesMoved?()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if append(touches: touches, event: event) {
            resetStroke()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if append(touches: touches, event: event) {
            resetStroke()
        }
    }
}
