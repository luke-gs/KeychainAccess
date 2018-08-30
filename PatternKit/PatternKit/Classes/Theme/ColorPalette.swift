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
    public static var shared = ColorPalette()

    open var orangeRed         = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
    open var sunflowerYellow   = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
    open var midGreen          = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
    open var darkBlue          = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    open var brightBlue        = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    open var skyBlue           = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)

    open var primaryGray       = #colorLiteral(red: 0.2470588235, green: 0.2509803922, blue: 0.2705882353, alpha: 1)
    open var secondaryGray     = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
    open var selectedGray      = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
    open var disabledGray      = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
    open var softGray          = #colorLiteral(red: 0.930967629, green: 0.9309893847, blue: 0.9309776425, alpha: 1)
    open var sidebarBlack      = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
    open var sidebarGray       = #colorLiteral(red: 0.1642476916, green: 0.1795658767, blue: 0.2130921185, alpha: 1)
    
    open var tabBarWhite       = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
    open var tabBarBlack       = #colorLiteral(red: 0.2645705938, green: 0.2645705938, blue: 0.2645705938, alpha: 1)
}

/// Convenience extension to UIColor
extension UIColor {

    public static var orangeRed         = ColorPalette.shared.orangeRed
    public static var midGreen          = ColorPalette.shared.midGreen
    public static var sunflowerYellow   = ColorPalette.shared.sunflowerYellow
    public static var darkBlue          = ColorPalette.shared.darkBlue
    public static var brightBlue        = ColorPalette.shared.brightBlue
    public static var skyBlue           = ColorPalette.shared.skyBlue

    public static var primaryGray       = ColorPalette.shared.primaryGray
    public static var secondaryGray     = ColorPalette.shared.secondaryGray
    public static var selectedGray      = ColorPalette.shared.selectedGray
    public static var disabledGray      = ColorPalette.shared.disabledGray
    public static var softGray          = ColorPalette.shared.softGray
    public static var sidebarBlack      = ColorPalette.shared.sidebarBlack
    public static var sidebarGray       = ColorPalette.shared.sidebarGray
    
    public static var tabBarWhite       = ColorPalette.shared.tabBarWhite
    public static var tabBarBlack       = ColorPalette.shared.tabBarBlack
}
