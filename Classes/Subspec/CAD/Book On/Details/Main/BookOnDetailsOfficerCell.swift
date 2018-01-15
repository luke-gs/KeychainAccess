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
        static let spacingX: CGFloat = 8
    }

    // MARK: - Views

    /// Rounded rect showing the officer status
    public let statusLabel = RoundedRectLabel(frame: .zero)

    // MARK: - Setup

    override public func commonInit() {
        super.commonInit()

        let theme = ThemeManager.shared.theme(for: .current)
        statusLabel.textColor = theme.color(forKey: .background)
        statusLabel.borderColor = theme.color(forKey: .primaryText)
        statusLabel.backgroundColor = theme.color(forKey: .primaryText)
        statusLabel.layoutMargins.left = 4
        statusLabel.layoutMargins.right = 4
        contentView.addSubview(statusLabel)
    }

    public override func layoutSubviews() {

        // Layout rest of cell
        super.layoutSubviews()

        // Check whether we need to clip the title label to fit the extra view in before the accessoryView
        let trailingX = (accessoryView?.frame.minX ?? contentView.frame.maxX) - LayoutConstants.spacingX * 2

        // Size label and position after title
        statusLabel.sizeToFit()
        var titleFrame = titleLabel.frame
        var statusFrame = CGRect(x: titleFrame.maxX + LayoutConstants.spacingX,
                                        y: titleFrame.origin.y + (titleFrame.height - statusLabel.frame.height) / 2,
                                        width: statusLabel.frame.width,
                                        height: statusLabel.frame.height)

        self.statusLabel.frame = statusFrame

        // Prevent the status label from going off screen if title is too long
        let overhang = statusFrame.maxX - trailingX
        if overhang > 0 {
            statusFrame.origin.x -= overhang
            titleFrame.size.width -= overhang
            self.statusLabel.frame = statusFrame
            self.titleLabel.frame = titleFrame
        }
    }
}
