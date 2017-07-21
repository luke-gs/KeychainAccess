//
//  UIImage+FormIcons.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
   
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .checkbox)")
    public static let checkbox = AssetManager.shared.image(forKey: .checkbox)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .checkboxSelected)")
    public static let checkboxSelected = AssetManager.shared.image(forKey: .checkboxSelected)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .radioButton)")
    public static let radioButton = AssetManager.shared.image(forKey: .radioButton)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .radioButtonSelected)")
    public static let radioButtonSelected = AssetManager.shared.image(forKey: .radioButtonSelected)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .disclosure)")
    public static let formAccessoryDisclosureIndicator = AssetManager.shared.image(forKey: .disclosure)!
    
    @nonobjc  @available(*, deprecated, message: "Use AssetManager.shared.image(forKey: .formCheckmark)")
    public static let formAccessoryCheckmark = AssetManager.shared.image(forKey: .formCheckmark)!
    
}
