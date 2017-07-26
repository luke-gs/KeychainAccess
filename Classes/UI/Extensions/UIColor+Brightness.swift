//
//  UIColor+Brightness.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Adjusts the brightness by the factor passed. For example, the following
    /// would create a red color with 75% the brightness of standard red:
    /// ```
    ///  UIColor.red.adjustingBrightness(byFactor: 0.75)
    /// ```
    ///
    /// - Parameter factor: The factor to muiltiply the brightness by.
    /// - Returns: An adjusted brightness color, or the color if it could not
    ///            be adjusted.
    public func adjustingBrightness(byFactor factor: CGFloat) -> UIColor {
        
        var hue:        CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha:      CGFloat = 0.0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue,
                           saturation: saturation,
                           brightness: min(max(brightness * factor, 0.0), 1.0),
                           alpha: alpha)
        } else {
            return self
        }
    }
    
}
