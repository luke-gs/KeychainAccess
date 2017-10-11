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
    func presentPopover(_ viewController: UIViewController, sourceView: UIView, sourceRect:CGRect, animated: Bool)
    func presentPopover(_ viewController: UIViewController, barButton: UIBarButtonItem, animated: Bool)
    func presentFormSheet(_ viewController: UIViewController, animated: Bool)
}

/// Extension to add support to any view controller
extension UIViewController: PopoverPresenter {
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
}
