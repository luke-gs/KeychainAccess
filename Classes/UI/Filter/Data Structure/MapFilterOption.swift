//
//  MapFilterOption.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A toggle option
open class MapFilterOption {

    /// Text to display next to the option
    open var text: String?
    
    /// Whether the option can be changed
    open var isEnabled: Bool
    
    /// Whether the option is on
    open var isOn: Bool
    
    /// - Parameters:
    ///   - identifier: the value of the option
    ///   - text: text to display next to the option
    ///   - isEnabled: whether the option can be changed. `true` by default
    ///   - isOn: whether the option is on
    public init(text: String?, isEnabled: Bool = true, isOn: Bool) {
        self.text = text
        self.isEnabled = isEnabled
        self.isOn = isOn
    }
    
}
