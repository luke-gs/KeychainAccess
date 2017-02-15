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
        if hex.hasPrefix("#") {
            hex = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
        }
        
        if hex.characters.count == 3 {
            hex = hex + "F"
        } else if hex.characters.count == 6 {
            hex = hex + "FF"
        }
        
        if (hex.range(of: "(^[0-9A-Fa-f]{8}$)|(^[0-9A-Fa-f]{4}$)", options: .regularExpression) == nil) { return nil }
        if hex.characters.count == 4 {
            let redHex    = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 1))
            let greenHex  = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 1) ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
            let blueHex   = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 3)))
            let alphaHex  = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 3))
            
            hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex + alphaHex + alphaHex
        }
        
        let redHex    = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 2))
        let greenHex  = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
        let blueHex   = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
        let alphaHex  = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 6) ..< hex.characters.index(hex.startIndex, offsetBy: 8)))
        
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
