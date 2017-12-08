//
//  PopoverPresenter.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// Protocol for a class that can present view controllers using the PopoverNavigationController
public protocol PopoverPresenter: class {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)

    func presentPopover(_ viewController: UIViewController, sourceView: UIView, sourceRect:CGRect, animated: Bool)
    func presentPopover(_ viewController: UIViewController, barButton: UIBarButtonItem, animated: Bool)
    func presentFormSheet(_ viewController: UIViewController, animated: Bool)

    // Convenience for target/action
    func dismiss()
}

// Protocol for a class that can present view controllers using a navigation controller
public protocol NavigationPresenter: class {
    func presentPushedViewController(_ viewController: UIViewController, animated: Bool)
    func popPushedViewController(animated: Bool) -> UIViewController?
}

/// Extension to add support to any view controller
extension UIViewController: PopoverPresenter, NavigationPresenter {

    public func presentFormSheet(_ viewController: UIViewController, animated: Bool) {
        let nav = PopoverNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }

    public func presentPopover(_ viewController: UIViewController, sourceView: UIView, sourceRect:CGRect, animated: Bool) {
        let nav = PopoverNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.sourceView = sourceView
        nav.popoverPresentationController?.sourceRect = sourceRect
        present(nav, animated: true, completion: nil)
    }

    public func presentPopover(_ viewController: UIViewController, barButton: UIBarButtonItem, animated: Bool) {
        let nav = PopoverNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.barButtonItem = barButton
        present(nav, animated: true, completion: nil)
    }

    public func presentPushedViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }

    public func popPushedViewController(animated: Bool) -> UIViewController? {
        return navigationController?.popViewController(animated: animated)
    }

    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

