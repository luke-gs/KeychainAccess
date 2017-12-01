//
//  UIViewController+Compact.swift
//  MPOLKit
//
//  Created by Kyle May on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Whether the view controller or the window is horizontal compact
    public func isCompact() -> Bool {
        // If it is called early enough, `self.traitCollection.horizontalSizeClass` will return .unspecified.
        // It'll inherit the value from upper chain so delegate that to the window.
        if self.traitCollection.horizontalSizeClass != .unspecified {
            return self.traitCollection.horizontalSizeClass == .compact
        }
        return UIViewController.isWindowCompact()
    }
    
    /// Is the key window being rendered in compact environment
    public static func isWindowCompact() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.horizontalSizeClass == .compact {
            return true
        }
        return false
    }
}
