//
//  UIViewController+Subtitle.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

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

    public func setTitleView(title: String, subtitle: String) {

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = themeColor(forKey: .primaryText)!
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = themeColor(forKey: .secondaryText)!
        subtitleLabel.sizeToFit()

        // Arrange in stackview for easy layout
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical

        let verticalPadding: CGFloat = 2 // not much, but we've gotta fit in the nav space
        let width = max(titleLabel.frame.width, subtitleLabel.frame.width)
        let height = titleLabel.frame.height + subtitleLabel.frame.height + verticalPadding
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        navigationItem.titleView = stackView

        // Observe changes to the theme
        NotificationCenter.default.addObserver(forName: .interfaceStyleDidChange, object: nil, queue: nil) { [unowned self] (notification) in
            titleLabel.textColor = self.themeColor(forKey: .primaryText)!
            subtitleLabel.textColor = self.themeColor(forKey: .secondaryText)!
        }
    }
}

