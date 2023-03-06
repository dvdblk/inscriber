//
//  Drawing.swift
//  Inscriber
//
//  Created by David Bielik on 05/03/2023.
//

import Foundation
import CoreGraphics
import PencilKit

/// Rasterization to a normalized 28x28 CGImage for single or multiple `PKStroke` can be done via this class.
/// https://apple.github.io/turicreate/docs/userguide/drawing_classifier/export-coreml.html#using-stroke-based-drawing-input
class Drawing {
    var drawing: NSMutableArray
    var stroke: NSMutableArray
    var min_x: CGFloat
    var min_y: CGFloat
    var max_x: CGFloat
    var max_y: CGFloat

    init() {
        drawing = NSMutableArray()
        stroke = NSMutableArray()
        min_x = CGFloat.greatestFiniteMagnitude
        max_x = 0.0
        min_y = CGFloat.greatestFiniteMagnitude
        max_y = 0.0
    }

    func pointCount(stroke i:Int) -> Int {
        let corresponding_stroke = drawing.object(at:i) as! NSArray
        return corresponding_stroke.count
    }

    func strokeCount() -> Int {
        return drawing.count
    }

    func point(stroke i:Int, point j:Int) -> CGPoint {
        let corresponding_stroke = drawing.object(at:i) as! NSArray
        let answer = corresponding_stroke.object(at:j) as! CGPoint
        return answer
    }

    func stroke(index i:Int) -> NSMutableArray {
        return drawing.object(at: i) as! NSMutableArray
    }

    func add(point P:CGPoint) {
        let x = P.x
        let y = P.y
        min_x = min(x, min_x)
        max_x = max(x, max_x)
        min_y = min(y, min_y)
        max_y = max(y, max_y)
        stroke.add(P)
    }

    func endStroke() {
        let new_stroke = NSMutableArray()
        new_stroke.addObjects(from: stroke as! [Any])
        drawing.add(new_stroke)
        stroke.removeAllObjects()
    }
    
    
    func normalized() -> Drawing {
        let new_drawing = Drawing()
        for i in 0..<self.strokeCount() {
            for j in 0..<self.pointCount(stroke: i) {
                let current_point = point(stroke: i, point: j)
                var new_x, new_y : CGFloat
                if (max_x == min_x) {new_x = min_x}
                else {
                    new_x = (current_point.x - min_x) * 255.0 / (max_x - min_x)
                }
                if (max_y == min_y) {new_y = min_y}
                else {
                    new_y = (current_point.y - min_y) * 255.0 / (max_y - min_y)
                }
                let new_point = CGPoint(x: new_x, y: new_y)
                new_drawing.add(point: new_point)
            }
            new_drawing.endStroke()
        }
        return new_drawing
    }

    func rasterized() -> CGImage {
        let D = self.normalized()
        let grayscale = CGColorSpaceCreateDeviceGray()
        let intermediate_bitmap_context = CGContext(
            data:nil, width:256, height:256, bitsPerComponent:8, bytesPerRow:0,
            space:grayscale, bitmapInfo:CGImageAlphaInfo.none.rawValue)
        intermediate_bitmap_context?.setStrokeColor(
            red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let transform = CGAffineTransform.identity
        let path = CGMutablePath()
        for strokeIndex in 0..<D.strokeCount() {
            let stroke = D.stroke(index: strokeIndex)
            let startPoint = D.point(stroke: strokeIndex, point: 0)
            path.move(to: startPoint, transform: transform)
            for point in stroke {
                path.addLine(to: point as! CGPoint, transform: transform)
            }
        }
        intermediate_bitmap_context?.setLineWidth(20.0)
        intermediate_bitmap_context?.beginPath()
        intermediate_bitmap_context?.addPath(path)
        intermediate_bitmap_context?.strokePath()
        let intermediate_image = intermediate_bitmap_context?.makeImage()

        let final_bitmap_context = CGContext(
            data:nil, width:28, height:28, bitsPerComponent:8, bytesPerRow:0,
            space:grayscale, bitmapInfo:CGImageAlphaInfo.none.rawValue)
        let final_rect = CGRect(x: 0.0, y: 0.0, width: 28.0, height: 28.0)
        final_bitmap_context?.draw(intermediate_image!, in: final_rect)
        return (final_bitmap_context?.makeImage())!
    }
}

extension PKStroke {
    var toDrawing: Drawing {
        let drawing = Drawing()
        
        for point in path {
            drawing.add(point: point.location)
        }
        drawing.endStroke()
        
        return drawing
    }
}
