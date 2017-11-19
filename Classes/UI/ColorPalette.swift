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
    open var midGreen          = #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
    open var brightBlue        = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    open var sunflowerYellow   = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)

    open var primaryGray       = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1)
    open var secondaryGray     = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
    open var disabledGray      = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
    open var sidebarBlack      = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
}

/// Convenience extension to UIColor
extension UIColor {

    public static var orangeRed         = ColorPalette.shared.orangeRed
    public static var midGreen          = ColorPalette.shared.midGreen
    public static var brightBlue        = ColorPalette.shared.brightBlue
    public static var sunflowerYellow   = ColorPalette.shared.sunflowerYellow

    public static var primaryGray       = ColorPalette.shared.primaryGray
    public static var secondaryGray     = ColorPalette.shared.secondaryGray
    public static var disabledGray      = ColorPalette.shared.disabledGray
    public static var sidebarBlack      = ColorPalette.shared.sidebarBlack
}
