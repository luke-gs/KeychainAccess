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
/// Both the content and header can be changed at any time.
///
open class ContainerWithHeaderViewController: UIViewController {

    /// Whether the header is only visible in compact size environment
    open var onlyVisibleWhenCompact: Bool = true {
        didSet {
            updateHeaderVisibility()
        }
    }

    /// The top layout constraint of the content view
    private var contentTopConstraint: NSLayoutConstraint?

    /// The header view to display below the navigation bar
    open var headerViewController: UIViewController? {
        didSet {
            guard oldValue != headerViewController else { return }

            // Cleanup old value
            if let oldValue = oldValue {
                oldValue.removeFromParentViewController()
                oldValue.view.removeFromSuperview()
            }

            // Add the new header view controller as a child
            if let headerViewController = headerViewController {
                addChildViewController(headerViewController)
                view.addSubview(headerViewController.view)
                headerViewController.didMove(toParentViewController: self)

                // Constrain header to top
                let headerView = headerViewController.view!
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: safeAreaOrLayoutGuideTopAnchor),
                    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
            }
            updateHeaderVisibility()
        }
    }

    /// The content view to display below the header
    open var contentViewController: UIViewController? {
        didSet {
            guard oldValue != contentViewController else { return }

            // Cleanup
            if let oldValue = oldValue {
                oldValue.removeFromParentViewController()
                oldValue.view.removeFromSuperview()
            }

            // Add the new content view controller as a child
           if let contentViewController = contentViewController {
                addChildViewController(contentViewController)
                view.addSubview(contentViewController.view)
                contentViewController.didMove(toParentViewController: self)

                // Constrain content to safe area
                let contentView = contentViewController.view!
                contentView.translatesAutoresizingMaskIntoConstraints = false
                contentTopConstraint = contentView.topAnchor.constraint(equalTo: safeAreaOrLayoutGuideTopAnchor, constant: 0)
                NSLayoutConstraint.activate([
                    contentTopConstraint!,
                    contentView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                    contentView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
                ])
            }
            updateHeaderVisibility()
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
        // Inset the content view the size of the header if visible, otherwise hide
        if let headerView = headerViewController?.view, shouldShowHeaderView() {
            // Force layout of header for sizing
            headerView.isHidden = false
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            contentTopConstraint?.constant = headerView.bounds.height
        } else {
            headerViewController?.view?.isHidden = true
            contentTopConstraint?.constant = 0
        }
    }
}

