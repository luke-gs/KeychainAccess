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

    /// Offset for above the header, or content if no header
    open var headerOffset: CGFloat = 0 {
        didSet {
            updateHeaderVisibility()
        }
    }
    
    /// Constraint for header offset
    private var headerTopConstraint: NSLayoutConstraint?

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
            }
            updateLayouts()
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
            }
            updateLayouts()
            updateHeaderVisibility()
        }
    }

    private var constraints: [NSLayoutConstraint] = []

    open func updateLayouts() {
        NSLayoutConstraint.deactivate(constraints)

        let headerView = headerViewController?.view
        let contentView = contentViewController?.view

        var newConstraints = [NSLayoutConstraint]()

        if let headerView = headerView {
            headerTopConstraint = headerView.topAnchor.constraint(equalTo: safeAreaOrLayoutGuideTopAnchor, constant: 0)
            newConstraints += [
                headerTopConstraint!,
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        }

        if let contentView = contentView {
            newConstraints += [
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]

            if let headerView = headerView {
                newConstraints.append(contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor))
            } else {
                contentTopConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: headerOffset)
                newConstraints.append(contentTopConstraint!)
            }
        }

        NSLayoutConstraint.activate(newConstraints)
        constraints = newConstraints
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
        updateLayouts()
        updateHeaderVisibility()
    }

    open func updateHeaderVisibility() {
        // Inset the content view the size of the header if visible, otherwise hide
        if let headerView = headerViewController?.view {
            // Force layout of header for sizing
            headerView.isHidden = false
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            headerTopConstraint?.constant = headerOffset
        } else {
            contentTopConstraint?.constant = headerOffset
            headerViewController?.view?.isHidden = true
        }
    }
}

