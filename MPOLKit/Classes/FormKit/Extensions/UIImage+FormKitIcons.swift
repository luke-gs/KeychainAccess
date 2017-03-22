//
//  UIImage+FormKitIcons.swift
//  FormKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    private class func formKitImage(named name: String, needsRtlFlipping: Bool = false) -> UIImage {
        let image = UIImage(named: name, in: Bundle(for: CollectionViewFormLayout.self), compatibleWith: nil)!
        
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
    public static let checkbox = formKitImage(named: "Checkbox")
    
    @nonobjc
    public static let checkboxSelected = formKitImage(named: "CheckboxFilled", needsRtlFlipping: true)
    
    @nonobjc
    public static let radioButton = formKitImage(named: "RadioFilled")
    
    @nonobjc
    public static let radioButtonSelected = formKitImage(named: "RadioButtonFilled")
    
    @nonobjc
    public static let formDisclosureIndicator = formKitImage(named: "FormDisclosureIndicator", needsRtlFlipping: true)
    
}
