//
//  BookOnDetailsOfficerCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Csutom collection view form cell for displaying officers
class BookOnDetailsOfficerCell: CollectionViewFormSubtitleCell {
    
    private struct LayoutConstants {
        static let spacingX: CGFloat = 4
    }

    // MARK: - Views

    /// Rounded rect showing the officer status
    public let statusLabel = RoundedRectLabel(frame: .zero)

    // MARK: - Setup

    override public func commonInit() {
        super.commonInit()

        let theme = ThemeManager.shared.theme(for: .current)
        statusLabel.textColor = theme.color(forKey: .primaryText)
        statusLabel.borderColor = statusLabel.textColor
        statusLabel.backgroundColor = .clear

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)
    }

    public override func layoutSubviews() {

        // Layout rest of cell
        super.layoutSubviews()

        // Get frame relative to top view
        let titleFrame = titleLabel.convert(titleLabel.bounds, to: self)

        // Size label and position after title
        statusLabel.sizeToFit()
        let statusFrame = CGRect(x: titleFrame.maxX + LayoutConstants.spacingX,
                             y: titleFrame.origin.y + (titleFrame.height - statusLabel.frame.height) / 2,
                             width: statusLabel.frame.width,
                             height: statusLabel.frame.height)

        if statusLabel.frame != statusFrame {
            DispatchQueue.main.async {
                self.statusLabel.frame = statusFrame
            }
        }
    }
}
