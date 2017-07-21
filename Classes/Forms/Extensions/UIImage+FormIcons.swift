//
//  UIImage+FormIcons.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/11/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
   
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .checkbox)")
    public static let checkbox = AssetManager.shared.image(for: .checkbox)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .checkboxSelected)")
    public static let checkboxSelected = AssetManager.shared.image(for: .checkboxSelected)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .radioButton)")
    public static let radioButton = AssetManager.shared.image(for: .radioButton)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .radioButtonSelected)")
    public static let radioButtonSelected = AssetManager.shared.image(for: .radioButtonSelected)!
    
    @nonobjc @available(*, deprecated, message: "Use AssetManager.shared.image(for: .disclosure)")
    public static let formAccessoryDisclosureIndicator = AssetManager.shared.image(for: .disclosure)!
    
    @nonobjc  @available(*, deprecated, message: "Use AssetManager.shared.image(for: .formCheckmark)")
    public static let formAccessoryCheckmark = AssetManager.shared.image(for: .formCheckmark)!
    
}
