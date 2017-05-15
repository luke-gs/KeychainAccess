//
//  UIContentSizeCategoryLegacyAdjusting.swift
//  Pods
//
//  Created by Rod Brown on 16/5/17.
//
//

import UIKit


extension UILabel {
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0)
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

extension UITextField {
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0)
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

extension UITextView {
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0)
    public func legacy_adjustFontForContentSizeCategoryChange() {
        if let fontTextStyle = font?.textStyle {
            font = .preferredFont(forTextStyle: fontTextStyle)
        }
    }
    
}

