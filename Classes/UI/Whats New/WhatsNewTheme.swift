//
//  WhatsNewTheme.swift
//  Pods
//
//  Created by Megan Efron on 14/8/17.
//
//

import UIKit

/// A theme class for `WhatsNewViewController`. To change theme per app, subclass and override
/// relevant properties, and set the `theme` property of your `WhatsNewViewController` to an
/// instance of your subclass.
open class WhatsNewTheme {
    
    public init() {}
    
    // TODO: Make some optionals where relevant
    
    open var backgroundColor: UIColor?              { return UIColor(hexString: "#FFFFFF") }
    
    // backgroundColor will be ignored if backgroundImage is not nil
    open var backgroundImage: UIImage?              { return nil }
    
    open var buttonFont: UIFont                     { return .systemFont(ofSize: 13.0, weight: UIFontWeightSemibold) }
    open var buttonSkipTextColor: UIColor?          { return UIColor(hexString: "#75828D") }
    open var buttonSkipBackgroundColor: UIColor?    { return UIColor(hexString: "#FFFFFF") }
    open var buttonSkipBorderColor: UIColor?        { return UIColor(hexString: "#75828D") }
    open var buttonSkipText: String                 { return "Skip" }
    open var buttonDoneTextColor: UIColor?          { return UIColor(hexString: "#FFFFFF") }
    open var buttonDoneBackgroundColor: UIColor?    { return UIColor(hexString: "#2B7DF6") }
    open var buttonDoneBorderColor: UIColor?        { return nil }
    open var buttonDoneText: String                 { return "Continue" }
    
    open var pageControlCurrentTintColor: UIColor?  { return UIColor(hexString: "#2B7DF6") }
    open var pageControlTintColor: UIColor?         { return UIColor(hexString: "#EEEEEE") }
    
    open var titleTextColor: UIColor                { return UIColor(hexString: "#565861")! }
    open var titleFont: UIFont                      { return .systemFont(ofSize: 28.0, weight: UIFontWeightBold) }
    
    open var detailTextColor: UIColor               { return UIColor(hexString: "#77828B")! }
    open var detailFont: UIFont                     { return .systemFont(ofSize: 17.0, weight: UIFontWeightRegular) }
}
