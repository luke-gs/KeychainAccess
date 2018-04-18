//
//  ColorPalette.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Color palette to use across PSCore apps, regardless of theme
open class ColorPalette: NSObject {

    /// Shared color palette which can be overriden
    open static var shared = ColorPalette()

    open var orangeRed         = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
    open var sunflowerYellow   = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
    open var midGreen          = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
    open var brightBlue        = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    open var skyBlue           = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
    

    open var primaryGray       = #colorLiteral(red: 0.2470588235, green: 0.2509803922, blue: 0.2705882353, alpha: 1)
    open var secondaryGray     = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
    open var disabledGray      = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
    open var sidebarBlack      = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
    
    open var tabBarWhite       = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
    open var tabBarBlack       = #colorLiteral(red: 0.2645705938, green: 0.2645705938, blue: 0.2645705938, alpha: 1)
}

/// Convenience extension to UIColor
extension UIColor {

    open static var orangeRed         = ColorPalette.shared.orangeRed
    open static var midGreen          = ColorPalette.shared.midGreen
    open static var sunflowerYellow   = ColorPalette.shared.sunflowerYellow
    open static var brightBlue        = ColorPalette.shared.brightBlue
    open static var skyBlue           = ColorPalette.shared.skyBlue

    open static var primaryGray       = ColorPalette.shared.primaryGray
    open static var secondaryGray     = ColorPalette.shared.secondaryGray
    open static var disabledGray      = ColorPalette.shared.disabledGray
    open static var sidebarBlack      = ColorPalette.shared.sidebarBlack
    
    open static var tabBarWhite       = ColorPalette.shared.tabBarWhite
    open static var tabBarBlack       = ColorPalette.shared.tabBarBlack
}
