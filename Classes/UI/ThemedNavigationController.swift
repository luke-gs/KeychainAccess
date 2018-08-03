//
//  ThemedNavigationController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Themed navigation controller that implements light/dark styling.
public class ThemedNavigationController: UINavigationController {
    /// Support for being transparent when in popover/form sheet
    open var wantsTransparentBackground: Bool = false {
        didSet {
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
            apply(ThemeManager.shared.theme(for: .current))
        }
    }

    /// The user interface style for the view.
    ///
    /// When set to `.current`, the theme autoupdates when the interface style changes.
    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }

            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }

            apply(ThemeManager.shared.theme(for: userInterfaceStyle))
        }
    }

    /// An optional dismiss handler.
    ///
    /// The themed navigation controller fires this when it is about to dismiss after
    /// being presented, and passes a boolean parameter, indicating whether the dismiss
    /// will be animated.
    ///
    /// You should use this method to avoid assigning yourself as the popover presentation controller's
    /// delegate, as this will interfere with the adaptive appearance APIs.
    open var dismissHandler: ((Bool) -> Void)?

    /// Return the theme to use, based on current interface style
    open var theme: Theme {
        return ThemeManager.shared.theme(for: userInterfaceStyle)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Observe theme changes if using current theme
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }

        apply(ThemeManager.shared.theme(for: .current))
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isBeingDismissed {
            dismissHandler?(animated)
        }
    }

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func apply(_ theme: Theme) {
        if isViewLoaded == false { return }

        let navigationBar = self.navigationBar
        let transparent = self.wantsTransparentBackground

        if transparent {
            navigationBar.tintColor   = nil
            navigationBar.barStyle    = userInterfaceStyle.isDark ? .black : .default
            navigationBar.setBackgroundImage(nil, for: .default)
        } else {
            navigationBar.barStyle      = theme.navigationBarStyle
            navigationBar.tintColor = theme.color(forKey: .tint)
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.color(forKey: .primaryText)!]
            navigationBar.backgroundColor = theme.color(forKey: .background)
            navigationBar.barTintColor = theme.color(forKey: .background)
            navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
}
