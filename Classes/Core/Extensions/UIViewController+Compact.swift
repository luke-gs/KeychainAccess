//
//  UIViewController+Compact.swift
//  MPOLKit
//
//  Created by Kyle May on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIViewController {

    public enum CompactType {
        case horizontal
        case vertical
    }

    /// Whether the view controller or the window is compact
    public func isCompact(_ type: CompactType = .horizontal) -> Bool {
        switch type {
        case .horizontal:
            return isCompactHorizontal()
        case .vertical:
            return isCompactVertical()
        }
    }

    /// Is the key window being rendered in compact environment
    public static func isWindowCompact(_ type: CompactType = .horizontal) -> Bool {
        switch type {
        case .horizontal:
            return isWindowCompactHorizontal()
        case .vertical:
            return isWindowCompactVertical()
        }
    }
    
    /// Whether the view controller or the window is horizontal compact
    private func isCompactHorizontal() -> Bool {
        // If it is called early enough, `self.traitCollection.horizontalSizeClass` will return .unspecified.
        // It'll inherit the value from upper chain so delegate that to the window.
        if self.traitCollection.horizontalSizeClass != .unspecified {
            return self.traitCollection.horizontalSizeClass == .compact
        }
        return UIViewController.isWindowCompactHorizontal()
    }

    /// Whether the view controller or the window is horizontal compact
    private func isCompactVertical() -> Bool {
        if self.traitCollection.verticalSizeClass != .unspecified {
            return self.traitCollection.verticalSizeClass == .compact
        }
        return UIViewController.isWindowCompactVertical()
    }

    /// Is the key window being rendered in compact environment
    private static func isWindowCompactHorizontal() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.horizontalSizeClass == .compact {
            return true
        }
        return false
    }

    /// Is the key window being rendered in compact environment
    private static func isWindowCompactVertical() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.verticalSizeClass == .compact {
            return true
        }
        return false
    }
}
