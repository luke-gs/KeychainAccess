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

    open var backgroundColor: UIColor?
    open var backgroundImage: UIImage?

    open var buttonFont: UIFont
    open var buttonSkipTextColor: UIColor?
    open var buttonSkipBackgroundColor: UIColor?
    open var buttonSkipBorderColor: UIColor?
    open var buttonSkipText: String
    open var buttonDoneTextColor: UIColor?
    open var buttonDoneBackgroundColor: UIColor?
    open var buttonDoneBorderColor: UIColor?
    open var buttonDoneText: String

    open var pageControlCurrentTintColor: UIColor?
    open var pageControlTintColor: UIColor?

    open var titleTextColor: UIColor
    open var titleFont: UIFont

    open var detailTextColor: UIColor
    open var detailFont: UIFont
    
    public init(theme: Theme) {

        backgroundColor = theme.color(forKey: .background)

        // backgroundColor will be ignored if backgroundImage is not nil
        backgroundImage = nil

        buttonFont = .systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
        buttonSkipTextColor = UIColor(hexString: "#75828D")
        buttonSkipBackgroundColor = UIColor(hexString: "#FFFFFF")
        buttonSkipBorderColor = UIColor(hexString: "#75828D")
        buttonSkipText = "Skip"
        buttonDoneTextColor = UIColor(hexString: "#FFFFFF")
        buttonDoneBackgroundColor = UIColor(hexString: "#2B7DF6")
        buttonDoneBorderColor = nil
        buttonDoneText = "Continue"

        pageControlCurrentTintColor = UIColor(hexString: "#2B7DF6")
        pageControlTintColor = UIColor(hexString: "#EEEEEE")

        titleTextColor = theme.color(forKey: .primaryText)!
        titleFont = .systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)

        detailTextColor = theme.color(forKey: .secondaryText)!
        detailFont = .systemFont(ofSize: 17.0, weight: UIFont.Weight.regular)
    }
}
