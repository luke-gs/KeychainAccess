//
//  UIColor+Hex.swift
//  MPOLKit/FormKit
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
        let hexStartIndex = hex.startIndex
        if hex.hasPrefix("#") {
            hex.remove(at: hexStartIndex)
        }
        
        if hex.characters.count == 3 {
            hex += "F"
        } else if hex.characters.count == 6 {
            hex += "FF"
        }
        
        if hex.range(of: "(^[0-9A-Fa-f]{8}$)|(^[0-9A-Fa-f]{4}$)", options: .regularExpression) == nil { return nil }
        
        let greenIndex: String.Index
        let blueIndex:  String.Index
        let alphaIndex: String.Index
        if hex.characters.count == 4 {
            hex.insert(hex[hexStartIndex], at: hexStartIndex)
            
            greenIndex = hex.index(hexStartIndex, offsetBy: 2)
            hex.insert(hex[greenIndex], at: greenIndex)
            
            blueIndex = hex.index(hexStartIndex, offsetBy: 4)
            hex.insert(hex[blueIndex], at: blueIndex)
            
            alphaIndex = hex.index(hexStartIndex, offsetBy: 6)
            hex.insert(hex[alphaIndex], at: alphaIndex)
        } else {
            greenIndex = hex.index(hexStartIndex, offsetBy: 2)
            blueIndex  = hex.index(hexStartIndex, offsetBy: 4)
            alphaIndex = hex.index(hexStartIndex, offsetBy: 6)
        }
        
        let redHex   = hex.substring(to: greenIndex)
        let greenHex = hex[greenIndex ..< blueIndex]
        let blueHex  = hex[blueIndex ..< alphaIndex]
        let alphaHex = hex.substring(from: alphaIndex)
        
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
