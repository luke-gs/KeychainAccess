//
//  UITraitCollection+CurrentDisplayScale.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/3/17.
//
//

import UIKit

extension UITraitCollection {
    
    /// The display scale of the trait collection, or the scale of the main screen if unspecified.
    public var currentDisplayScale: CGFloat {
        let displayScale = self.displayScale
        if displayScale ==~ 0.0 {
            return UIScreen.main.scale
        }
        return displayScale
    }
    
}
