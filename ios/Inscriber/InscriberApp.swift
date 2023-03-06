//
//  InscriberApp.swift
//  Inscriber
//
//  Created by David Bielik on 04/03/2023.
//

import SwiftUI

@main
struct InscriberApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DrawingView()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
