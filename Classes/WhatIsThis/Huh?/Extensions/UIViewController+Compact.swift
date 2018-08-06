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
        return windowTraitCollection.horizontalSizeClass == .compact
    }

    /// Is the key window being rendered in compact environment
    private static func isWindowCompactVertical() -> Bool {
        return windowTraitCollection.verticalSizeClass == .compact
    }

    private static var windowTraitCollection: UITraitCollection {
        // Return the key window's trait collection if the app has finished launching
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.traitCollection
        }

        // Fallback to a temp window trait collection for cases where we are still constructing views for the main
        // window's root view controller when needing to know if they will render in a compact environment
        return tempWindow.traitCollection
    }

    /// Lazily created temp window for checking traits when no keyWindow
    private static var tempWindow: UIWindow = UIWindow()
}
