//
//  ActiveStrokeContext.swift
//  Inscriber
//
//  Created by David Bielik on 06/03/2023.
//

import UIKit
import PencilKit

/// Represents the currently active `PKStroke` by an array of captured points (`[PKStrokePoint]`) and the state of drawing this stroke.
class ActiveStrokeContext {
    
    // MARK: - Stroke State
    /// State of a stroke context. The user can be actively drawing or about to finish a drawing.
    enum State {
        /// When the user is actively drawing
        case drawing
        /// When the user is about to finish his drawing (stop moving the input device)
        case finishing
        /// When the app is presenting an alternative to this active stroke (e.g. ML prediction of a Shape)
        //case presentedAlternative
    }
    
    var state: State = .drawing {
        didSet {
            switch (oldValue, state) {
            case (.drawing, .finishing):
                strokeFinishingAction?(stroke)
            case (.finishing, .drawing):
                strokeContinueDrawingAction?()
            case (.drawing, .drawing), (.finishing, .finishing):
                // ignore
                break
            }
        }
    }
    
    /// Used to change the state based on user's intention. Whenever the user doesn't leave a certain vicinity for some amount of time / pkstrokepoints
    /// the state changes to .finishing
    private var drawingTimeoutTimer: Timer?
    /// The index of a `PKStrokePoint` that was tagged as the point around which to calculate the finishing vicinity of the stroke.
    private var drawingTimeoutReferencePointIndex: Int?
    
    var strokeFinishingAction: ((PKStroke) -> Void)?
    var strokeContinueDrawingAction: (() -> Void)?
    
    // MARK: - Constants
    /// The timeout before a timer considers to change the stroke state
    private static let drawingTimeout: TimeInterval = 0.5
    /// The radius around the last stroke that was considered during the timer reset
    private static let finishingVicinityRadius: CGFloat = 24
    
    // MARK: - Stroke
    private var strokePoints = [PKStrokePoint]()
    
    var stroke: PKStroke {
        let ink = inkingTool.ink
        let path = PKStrokePath(
            controlPoints: strokePoints,
            creationDate: Date()
        )
        return PKStroke(ink: ink, path: path)
    }
    
    // MARK: - Init
    let trackedTouch: UITouch
    let initialTimestamp: TimeInterval
    let inkingTool: PKInkingTool
    
    init(tool: PKInkingTool, initialTouch: UITouch) {
        self.inkingTool = tool
        trackedTouch = initialTouch
        initialTimestamp = initialTouch.timestamp
        // Start the timer immediately
        resetTimer()
    }
    
    // MARK: - Stroke State Management
    /// Resets the timer and sets a completion handler that checks whether the last n points in strokePoints are inside of a vicinity w.r.t. a reference point.
    func resetTimer() {
        self.drawingTimeoutTimer?.invalidate()
        self.drawingTimeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.drawingTimeout, repeats: false) { [weak self] _ in
            guard let self = self, self.strokePoints.count > 2 else { return }
            // if the strokePoints haven't gone out of the vicinity of the referenced point,
            // set state to finishing
            self.state = .finishing
        }
    }
        
    // MARK: - Stroke Data Collection
    /// Appends touch data to the stroke sample.
    /// - Tag: appendTouches
    /// - Returns: `true` if touches were appended, `false` otherwise
    @discardableResult
    func append(touches: Set<UITouch>, view: UIView, event: UIEvent?) -> Bool {
        // Check that we have a touch to append, and that touches
        // doesn't contain it.
        guard touches.contains(trackedTouch) == true
        else { return false }
        // Collect coalesced touches
        if let event = event, let coalescedTouches = event.coalescedTouches(for: trackedTouch) {
            let lastIndex = coalescedTouches.count - 1
            for index in 0..<lastIndex {
                saveStrokePoint(touch: coalescedTouches[index], view: view, coalesced: true)
            }
            saveStrokePoint(touch: coalescedTouches[lastIndex], view: view, coalesced: false)
        }
        
        return true
    }
    
    func saveStrokePoint(touch: UITouch, view: UIView, coalesced: Bool) {
        // Only collect samples that actually moved in 2D space.
        let location = touch.preciseLocation(in: view)
        if let previousSample = strokePoints.last {
            // quadrance < 2 is very close to what the default behavior of PKCanvasView is doing
            // during the construction of the last PKStroke, the difference between captured points
            // is usually minimal
            if (previousSample.location - location).quadrance <= 2 {
                return
            }
        }
        
        // 45 degrees
        var azimuth: CGFloat = 45 * .pi / 180
        var altitutde: CGFloat = 45 * .pi / 180
        if touch.type == .pencil {
            azimuth = touch.azimuthAngle(in: view)
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
        
        if let lastReferencePointIndex = drawingTimeoutReferencePointIndex {
            // Check if the new strokePoint is outside of the radius of the last reference point
            let referencePoint = strokePoints[lastReferencePointIndex]
            if strokePoint.location.distance(to: referencePoint.location) > Self.finishingVicinityRadius {
                // strokePoint is outside of the radius
                // Set the reference point for next vicinity to strokePoint
                self.drawingTimeoutReferencePointIndex = strokePoints.count
                // Set state to drawing
                self.state = .drawing
                // Reset the timer
                self.resetTimer()
            }
        } else {
            // Otherwise add a reference point index if there is none
            drawingTimeoutReferencePointIndex = strokePoints.count
        }
        
        // Add the new strokePoint to the array
        strokePoints.append(strokePoint)
    }
}
