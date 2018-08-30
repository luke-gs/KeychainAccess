//
//  ThemedPopoverViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Base class for popover view controllers that need to react to theme changes
open class ThemedPopoverViewController: UIViewController, PopoverViewController {

    /// Support for being transparent when in popover/form sheet
    open var wantsTransparentBackground: Bool = false {
        didSet {
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
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
    }

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func apply(_ theme: Theme) {
        view.backgroundColor = wantsTransparentBackground ? .clear : theme.color(forKey: .background)
    }
}
