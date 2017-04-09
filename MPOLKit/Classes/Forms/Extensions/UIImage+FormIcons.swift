//
//  UIImage+FormIcons.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    private class func formImage(named name: String, needsRtlFlipping: Bool = false) -> UIImage {
        let image = UIImage(named: name, in: .mpolKit, compatibleWith: nil)!
        
        if #available(iOS 10, *) {
            // RTL flipping is handled by the image asset in iOS 10.
            // The needsRltFlipping value is only required for iOS 9 support.
            return image
        }
        
        if needsRtlFlipping == false || image.flipsForRightToLeftLayoutDirection {
            return image
        } else {
            return image.imageFlippedForRightToLeftLayoutDirection()
        }
    }
   
    @nonobjc
    public static let checkbox = formImage(named: "Checkbox")
    
    @nonobjc
    public static let checkboxSelected = formImage(named: "CheckboxFilled", needsRtlFlipping: true)
    
    @nonobjc
    public static let radioButton = formImage(named: "RadioFilled")
    
    @nonobjc
    public static let radioButtonSelected = formImage(named: "RadioButtonFilled")
    
    @nonobjc
    public static let formDisclosureIndicator = formImage(named: "FormDisclosureIndicator", needsRtlFlipping: true)
    
}
