//
//  UIColor+Hex.swift
//  VCom
//
//  Created by Rod Brown on 19/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Creates a color with in the given hex string and alpha.
    ///
    /// - Parameter hexString: The hex string, with or without the hash character. Supports RGB or RGBA hex values.
    /// - Returns: A color with the given hex string and alpha, or `nil` if the hex string was invalid.
    public convenience init?(hexString: String) {
        var hex = hexString
        
        // Check for and remove the hash
        let hexStart = hex.startIndex
        if hex.hasPrefix("#") {
            hex.remove(at: hexStart)
        }
        
        if hex.characters.count == 3 {
            hex = hex + "F"
        } else if hex.characters.count == 6 {
            hex = hex + "FF"
        }
        
        if (hex.range(of: "(^[0-9A-Fa-f]{8}$)|(^[0-9A-Fa-f]{4}$)", options: .regularExpression) == nil) { return nil }
        
        if hex.characters.count == 4 {
            hex.insert(hex[hexStart], at: hexStart)
            hex.insert(hex[hex.index(hexStart, offsetBy: 2)], at: hex.index(hexStart, offsetBy: 2))
            hex.insert(hex[hex.index(hexStart, offsetBy: 4)], at: hex.index(hexStart, offsetBy: 4))
            hex.insert(hex[hex.index(hexStart, offsetBy: 6)], at: hex.index(hexStart, offsetBy: 6))
        }
        
        let redHex   = hex.substring(to: hex.index(hexStart, offsetBy: 2))
        let greenHex = hex[hex.index(hexStart, offsetBy: 2) ..< hex.index(hexStart, offsetBy: 4)]
        let blueHex  = hex[hex.index(hexStart, offsetBy: 4) ..< hex.index(hexStart, offsetBy: 6)]
        let alphaHex = hex.substring(from: hex.index(hexStart, offsetBy: 6))
        
        var redInt:   CUnsignedInt = 0
        var greenInt: CUnsignedInt = 0
        var blueInt:  CUnsignedInt = 0
        var alphaInt: CUnsignedInt = 0
        
        Scanner(string: redHex).scanHexInt32(&redInt)
        Scanner(string: greenHex).scanHexInt32(&greenInt)
        Scanner(string: blueHex).scanHexInt32(&blueInt)
        Scanner(string: alphaHex).scanHexInt32(&alphaInt)
        
        self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alphaInt) / 255.0)
    }
}
