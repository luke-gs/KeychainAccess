//
//  UIFont+Digits.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIFont {

    /// Create a new font based on the current font but with monospaced digits when displaying numbers
    public func monospacedDigitFont() -> UIFont {
        let featureSettings = [
            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType as NSNumber,
            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector as NSNumber
        ]
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings : [featureSettings]]
        let newFontDescriptor = fontDescriptor.addingAttributes(fontDescriptorAttributes)
        return UIFont(descriptor: newFontDescriptor, size: pointSize)
    }
}
