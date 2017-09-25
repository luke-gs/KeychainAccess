//
//  UIViewController+SafeArea.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

/// Extension to allow simpler support for iOS 10 and 11 anchors
extension UIViewController {

    /// Anchor for top of safe area, or bottom of top layout guide
    var safeAreaOrLayoutGuideTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }

    /// Anchor for bottom of safe area, or top of bottom layout guide
    var safeAreaOrLayoutGuideBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }

    /// Convenience method for positioning a UI control above the safe area if additional safe area insets are used
    /// that take into account the control. Eg. Navigation Bar extension
    func constraintAboveSafeAreaOrBelowTopLayout(_ viewToPosition: UIView) -> NSLayoutConstraint {
        if #available(iOS 11, *) {
            return viewToPosition.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            return viewToPosition.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        }
    }
}
