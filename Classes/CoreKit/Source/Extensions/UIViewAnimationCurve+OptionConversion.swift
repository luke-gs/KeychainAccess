//
//  UIViewAnimationCurve+OptionConversion.swift
//  MPOLKit
//
//  Created by Rod Brown on 12/4/17.
//
//

import UIKit

extension UIViewAnimationCurve {
    
    /// An animation option translation of a UIViewAnimationCurve
    var animationOption: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(self.rawValue << 16))
    }
    
}
