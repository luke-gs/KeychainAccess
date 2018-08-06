//
//  UIView+SafeArea.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

/// Extension to allow simpler support for iOS 10 and 11 anchors
extension UIView {

    /// Anchor for top of safe area, or fallback to top of view
    public var safeAreaOrFallbackTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }

    /// Anchor for bottom of safe area, or fallback to bottom of view
    public var safeAreaOrFallbackBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }

    /// Anchor for leading of safe area, or fallback to leading of view
    public var safeAreaOrFallbackLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leadingAnchor
        } else {
            return leadingAnchor
        }
    }

    /// Anchor for trailing of safe area, or fallback to trailing of view
    public var safeAreaOrFallbackTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.trailingAnchor
        } else {
            return trailingAnchor
        }
    }

    // MARK: - Deprecated

    /// Do not use following unless leading or trailing is not applicable.
    /// Eg LoadingStateManager which does not yet use NSDirectionalEdgeInsets

    /// Anchor for left of safe area, or fallback to left of view
    @available(iOS, deprecated: 11.0, message: "Use `safeAreaOrFallbackLeadingAnchor` instead.")
    var safeAreaOrFallbackLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        } else {
            return leftAnchor
        }
    }

    @available(iOS, deprecated: 11.0, message: "Use `safeAreaOrFallbackTrailingAnchor` instead.")
    var safeAreaOrFallbackRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        } else {
            return rightAnchor
        }
    }

}
