//
//  UIColor+Hex.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Creates a color with in the given 6 or 8 character RGBA hex string.
    ///
    /// - Parameter hexString: The hex string, with or without the hash character. Supports 6 and 8 character RGB or RGBA hex values.
    /// - Returns: A color with the given hex string and alpha, or `nil` if the hex string was invalid.
    public convenience init?(hexString: String) {
        let hasHash = hexString.hasPrefix("#")
        let rgba: Bool
        
        switch (hexString.characters.count, hasHash) {
        case (6, false), (7, true):  rgba = false
        case (8, false), (9, true):  rgba = true
        default: return nil
        }
        
        let scanner = Scanner(string: hexString)
        if hasHash { scanner.scanLocation = 1 }
        
        var hexValue:  UInt32 = 0
        guard scanner.scanHexInt32(&hexValue) else { return nil }
        
        let divisor = CGFloat(255)
        if rgba {
            let red     = CGFloat((hexValue & 0xFF000000) >> 24) / divisor
            let green   = CGFloat((hexValue & 0x00FF0000) >> 16) / divisor
            let blue    = CGFloat((hexValue & 0x0000FF00) >>  8) / divisor
            let alpha   = CGFloat( hexValue & 0x000000FF       ) / divisor
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            let red     = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
            let green   = CGFloat((hexValue & 0x00FF00) >>  8) / divisor
            let blue    = CGFloat( hexValue & 0x0000FF       ) / divisor
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
}
