//
//  CompactFormSheetNavigationController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A navigation controller for managing the presentation of a form sheet style dialog in a compact size class
open class CompactFormSheetNavigationController: UINavigationController {

    public init(rootViewController: UIViewController, parent: UIViewController) {
        super.init(rootViewController: rootViewController)

        // Override navigation bar appearance to be transparent
        navigationBar.barStyle = ThemeManager.shared.currentInterfaceStyle.isDark ? .black : .default
        navigationBar.tintColor = nil
        navigationBar.setBackgroundImage(nil, for: .default)

        // Present the source selection as a centered popover, rather than form sheet, so we can control size
        modalPresentationStyle = .popover
        popoverPresentationController?.permittedArrowDirections = []
        popoverPresentationController?.sourceView = parent.view
        popoverPresentationController?.sourceRect = parent.view.bounds
        popoverPresentationController?.delegate = self
        presentationController?.delegate = self
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update the source rect so the popover stays centered on rotation
        if let parent = presentingViewController {
            coordinator.animate(alongsideTransition: { (context) in
                self.popoverPresentationController?.sourceRect = parent.view.bounds
            }, completion: nil)
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ThemeManager.shared.currentInterfaceStyle.isDark {
            // Use dark background for dark theme, as glass effect does not work
            // We brighten the theme background color, to provide contrast to view below
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = theme.color(forKey: .background)?.adjustingBrightness(byFactor: 1.2)
        } else {
            // Make background "glassy"
            view.backgroundColor = .clear
        }
        viewControllers.first?.view.backgroundColor = UIColor.clear
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CompactFormSheetNavigationController: UIAdaptivePresentationControllerDelegate {

    /// Present view controllers using requested style, regardless of device
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /// Present view controllers using requested style, regardless of device
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension CompactFormSheetNavigationController: UIPopoverPresentationControllerDelegate {

    /// Prevent closing of popover
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}
