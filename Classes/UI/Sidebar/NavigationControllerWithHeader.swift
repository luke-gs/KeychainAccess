//
//  NavigationControllerWithHeader.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

//
// Custom UINavigationController that makes space for a header view
// Note: we need different solutions for iOS10/11 due to additionalSafeAreaInsets
//
open class NavigationControllerWithHeader: UINavigationController {

    // Whether the header is only visible in compact size environment
    open var onlyVisibleWhenCompact: Bool = true

    // The header view to display below the navigation bar
    open var headerView: UIView? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            if let headerView = headerView {
                // Add header view and force layout so we know height for insets
                view.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                    headerView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
                ])
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
            }
        }
    }

    open func isHeaderViewVisible() -> Bool {
        return !onlyVisibleWhenCompact || UIScreen.main.traitCollection.horizontalSizeClass == .compact
    }

    // iOS 11
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 11.0, *) {
            if let headerView = headerView, isHeaderViewVisible() {
                headerView.isHidden = false
                additionalSafeAreaInsets = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
            } else {
                headerView?.isHidden = true
                additionalSafeAreaInsets = .zero
            }
        }
    }

    // iOS 10
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            return
        }

        if let headerView = headerView, isHeaderViewVisible() {
            headerView.isHidden = false
            let originY = self.navigationBar.frame.maxY + headerView.bounds.height
            if let contentView = view.subviews.first {
                if contentView.frame.origin.y != originY {
                    var newFrame = view.frame
                    newFrame.origin.y = originY
                    newFrame.size.height = view.frame.height - originY
                    contentView.frame = newFrame
                    contentView.setNeedsLayout()
                }
            }
        } else {
            headerView?.isHidden = true
            if let contentView = view.subviews.first {
                contentView.frame = view.frame
            }
        }
    }
}
