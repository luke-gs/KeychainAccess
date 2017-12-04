//
//  DisableableButton.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// `UIButton` subclass with ability to set disabled color
open class DisableableButton: UIButton {
    
    /// The color in the enabled state
    open var enabledColor: UIColor = .brightBlue {
        didSet {
            setTintColorForState()
        }
    }
    
    /// The color in the disabled state
    open var disabledColor: UIColor = .disabledGray {
        didSet {
            setTintColorForState()
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            setTintColorForState()
        }
    }
    
    private func setTintColorForState() {
        tintColor = isEnabled ? enabledColor : disabledColor
    }
}
