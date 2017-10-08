//
//  ContainerWithHeaderViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

///
/// Container view controller for showing a content view controller with an optional header.
///
/// Notes:
/// * Navigation items of content view controller are forwarded so this can be used in a UINavigationController.
///
open class ContainerWithHeaderViewController: UIViewController {

    /// Whether the header is only visible in compact size environment
    open var onlyVisibleWhenCompact: Bool = true

    /// The top layout constraint of the content view
    open var contentTopConstraint: NSLayoutConstraint?

    // The header view to display below the navigation bar
    open var headerView: UIView? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            if let headerView = headerView {
                // Add header view, using top layout guide to position below navigation bar
                view.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
                updateHeaderVisibility()
            }
        }
    }

    open var contentViewController: UIViewController? {
        didSet {
            if oldValue == contentViewController {
                return
            }
            // Cleanup
            if let oldValue = oldValue {
                oldValue.removeFromParentViewController()
                oldValue.view.removeFromSuperview()
            }

            if let contentViewController = contentViewController {
                // Add the content view controller as a child
                addChildViewController(contentViewController)
                view.addSubview(contentViewController.view)
                contentViewController.didMove(toParentViewController: self)

                // Constrain content to safe area
                let contentView = contentViewController.view!
                contentView.translatesAutoresizingMaskIntoConstraints = false
                contentTopConstraint = contentView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: 0)
                NSLayoutConstraint.activate([
                    contentTopConstraint!,
                    contentView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                    contentView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
                ])
            }
        }
    }

    /// Return whether header view should be shown, if available
    open func shouldShowHeaderView() -> Bool {
        if let traitCollection = UIApplication.shared.keyWindow?.rootViewController?.traitCollection,
            traitCollection.horizontalSizeClass == .compact {
            return true
        }
        return !onlyVisibleWhenCompact
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHeaderVisibility()
    }

    open func updateHeaderVisibility() {
        // Inset the content view the size of the header if visible
        if let headerView = headerView, shouldShowHeaderView() {
            // Force layout of header for sizing
            headerView.isHidden = false
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            contentTopConstraint?.constant = headerView.bounds.height
        } else {
            headerView?.isHidden = true
            contentTopConstraint?.constant = 0
        }
    }
}

