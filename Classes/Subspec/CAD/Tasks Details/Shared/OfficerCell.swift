//
//  OfficerCell.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Custom form cell for displaying an officer.
///
/// This uses the standard CollectionViewFormSubtitleCell, but adds a badge label
/// and buttons for comms
open class OfficerCell: CollectionViewFormSubtitleCell {
    
    private struct LayoutConstants {
        static let spacingX: CGFloat = 8
    }

    /// Badge label
    public let badgeLabel = RoundedRectLabel(frame: .zero)
    public var leftLayoutMargin: CGFloat? {
        didSet {
            applyLeftLayoutMargin()
        }
    }
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let badgeColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        badgeLabel.backgroundColor = .clear
        badgeLabel.borderColor = badgeColor
        badgeLabel.textColor = badgeColor
        addSubview(badgeLabel)
        
        imageAlignment = .center
        titleLabel.textColor = .primaryGray
        subtitleLabel.textColor = .secondaryGray
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Check whether we need to clip the title label to fit the extra view in before the accessoryView
        let trailingX = (accessoryView?.frame.minX ?? contentView.frame.maxX) - LayoutConstants.spacingX * 2
        
        // Size label and position after title
        badgeLabel.sizeToFit()
        var titleFrame = titleLabel.frame
        var badgeFrame = CGRect(x: titleFrame.maxX + LayoutConstants.spacingX,
                                 y: titleFrame.origin.y + (titleFrame.height - badgeLabel.frame.height) / 2,
                                 width: badgeLabel.frame.width,
                                 height: badgeLabel.frame.height)
        
        self.badgeLabel.frame = badgeFrame
        
        // Prevent the status label from going off screen if title is too long
        let overhang = badgeFrame.maxX - trailingX
        if overhang > 0 {
            badgeFrame.origin.x -= overhang
            titleFrame.size.width -= overhang
            self.badgeLabel.frame = badgeFrame
            self.titleLabel.frame = titleFrame
        }
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        applyLeftLayoutMargin()
    }
    
    private func applyLeftLayoutMargin() {
        if let leftLayoutMargin = leftLayoutMargin {
            layoutMargins.left = leftLayoutMargin
            contentView.layoutMargins.left = leftLayoutMargin
        }
    }
    
}
