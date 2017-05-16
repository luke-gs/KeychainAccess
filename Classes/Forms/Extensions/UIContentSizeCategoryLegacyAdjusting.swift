//
//  UIContentSizeCategoryLegacyAdjusting.swift
//  Pods
//
//  Created by Rod Brown on 16/5/17.
//
//

import UIKit


extension UILabel {
    
    /// Updates the font for the current content size category.
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0, message: "Use the adjustsFontForContentSizeCategory property on iOS 10 and later.")
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

extension UITextField {
    
    /// Updates the font for the current content size category.
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0, message: "Use the adjustsFontForContentSizeCategory property on iOS 10 and later.")
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

extension UITextView {
    
    /// Updates the font for the current content size category.
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0, message: "Use the adjustsFontForContentSizeCategory property on iOS 10 and later.")
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

