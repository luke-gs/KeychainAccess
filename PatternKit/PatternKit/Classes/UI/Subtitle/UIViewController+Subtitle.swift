//
//  UIViewController+Subtitle.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Global var for unique address as the assoc object handle
private var associatedObjectTitleViewHandle: UInt8 = 0

/// Extension to support navigation items with title and subtitle
///
/// The reason this is on the view controller and not the navigation item itself is because we
/// need to know the size class for text colors when rendered in a popover navigation controller
extension UIViewController {

    private func themeColor(forKey key: Theme.ColorKey) -> UIColor? {
        // When compact we always use white, to give contrast on blue navigation bar
        if traitCollection.horizontalSizeClass == .compact {
            return UIColor.white
        } else {
            return ThemeManager.shared.theme(for: .current).color(forKey: key)
        }
    }

    public func setTitleView(title: String?, subtitle: String?) {
        let titleView = NavigationTitleView(title: title, subtitle: subtitle)
        
        titleView.titleLabel.textColor = themeColor(forKey: .primaryText)!
        titleView.subtitleLabel.textColor = themeColor(forKey: .secondaryText)!

        navigationItem.titleView = titleView

        // Observe changes to the theme
        self.navTitleView = titleView
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleChanged), name: .interfaceStyleDidChange, object: nil)
    }

    @objc open func interfaceStyleChanged() {
        self.navTitleView?.titleLabel.textColor = self.themeColor(forKey: .primaryText)!
        self.navTitleView?.subtitleLabel.textColor = self.themeColor(forKey: .secondaryText)!
    }


    /// The NavigationTitleView, stored as an associated object, so we can update it on theme changes
    private var navTitleView: NavigationTitleView? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectTitleViewHandle) as? NavigationTitleView
        }
        set {
            // Store a weak reference to the view
            objc_setAssociatedObject(self, &associatedObjectTitleViewHandle, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
