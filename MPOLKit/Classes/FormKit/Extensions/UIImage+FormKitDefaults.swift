//
//  UIImage+FormKitDefaults.swift
//  FormKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    private class func templateImage(named name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: CollectionViewFormLayout.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
    }
   
    @nonobjc
    public static let checkbox = templateImage(named: "Checkbox")
    
    @nonobjc
    public static let checkboxSelected = templateImage(named: "CheckboxFilled")
    
    @nonobjc
    public static let radioButton = templateImage(named: "RadioFilled")
    
    @nonobjc
    public static let radioButtonSelected = templateImage(named: "RadioButtonFilled")
    
    @nonobjc
    public static let formDisclosureIndicator = templateImage(named: "FormDisclosureIndicator").imageFlippedForRightToLeftLayoutDirection()
    
}
