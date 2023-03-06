//
//  UIDevice+userInterface.swift
//  Inscriber
//
//  Created by David Bielik on 06/03/2023.
//

import UIKit

extension UIDevice {
    static var interfaceIsPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
