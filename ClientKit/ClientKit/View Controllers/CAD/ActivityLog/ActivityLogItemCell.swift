//
//  ActivityLogItemCell.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Custom form cell for displaying an activity log item.
///
/// This uses the standard CollectionViewFormSubtitleCell, but adds a label for the
/// time of the entry and positions the icon image inline with the title label.
open class ActivityLogItemCell: CollectionViewFormSubtitleCell {

    /// Time label for timeline item
    public let timeLabel = UILabel(frame: .zero)

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // Add time label
        timeLabel.font = subtitleLabel.font.monospacedDigitFont()
        timeLabel.textColor = #colorLiteral(red: 0.4588235294, green: 0.5098039216, blue: 0.5529411765, alpha: 1)
        addSubview(timeLabel)

        imageAlignment = .title
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func layoutSubviews() {
        // Size label to make space for it
        timeLabel.sizeToFit()

        // Layout rest of cell, using titleContentInset to make space for label
        titleContentInset = timeLabel.frame.width + 20
        super.layoutSubviews()

        // Center label vertically, and position after icon
        timeLabel.frame = CGRect(x: imageView.frame.maxX + 10,
                                 y: imageView.frame.origin.y + (imageView.frame.height - timeLabel.frame.height) / 2,
                                 width: timeLabel.frame.width,
                                 height: timeLabel.frame.height)
    }
}
