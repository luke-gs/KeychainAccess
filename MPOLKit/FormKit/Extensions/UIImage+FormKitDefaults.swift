//
//  UIImage+FormKitDefaults.swift
//  FormKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    private class func templateImage(withName name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: CollectionViewFormLayout.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
    }
   
    @nonobjc
    public static let checkbox = templateImage(withName: "Checkbox")
    
    @nonobjc
    public static let checkboxSelected = templateImage(withName: "CheckboxSelected")
    
    @nonobjc
    public static let radioButton = templateImage(withName: "RadioButton")
    
    @nonobjc
    public static let radioButtonSelected = templateImage(withName: "RadioButtonSelected")
    
}
