//
//  DrawingView.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI

struct DrawingView: View {
    var body: some View {
        PKCanvasRepresentation()
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            DrawingView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
                .previewDisplayName("iPad")
            DrawingView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("iPhone")
                
        }
    }
}
