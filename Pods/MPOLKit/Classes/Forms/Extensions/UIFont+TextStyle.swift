//
//  UIFont+TextStyle.swift
//  MPOLKit
//
//  Created by Rod Brown on 14/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var FontAssociatedTextStyleHandle: UInt8 = 0

extension UIFont {
    
    /// The text style for the font. This is a cached computed property.
    public var textStyle: UIFontTextStyle? {
        let styleString: NSString
        
        if let textStyleString = objc_getAssociatedObject(self, &FontAssociatedTextStyleHandle) as? NSString {
            styleString = textStyleString
        } else {
            let textStyleString = fontDescriptor.object(forKey: UIFontDescriptorTextStyleAttribute) as? NSString ?? NSString()
            objc_setAssociatedObject(self, &FontAssociatedTextStyleHandle, textStyleString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            styleString = textStyleString
        }
        
        if styleString.length == 0 {
            return nil // empty style string represents we previously tried to find a text style, and it didn't exist.
        }
        return UIFontTextStyle(rawValue: styleString as String)
    }
    
}
