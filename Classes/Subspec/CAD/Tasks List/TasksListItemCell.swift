//
//  TasksListItemCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Custom form cell for representing a task list item
public class TasksListItemCell: CollectionViewFormSubtitleCell {

    private struct PriorityConstants {
        static let width: CGFloat = 24
        static let height: CGFloat = 16
        static let textMargin: CGFloat = 4
        static let spacingX: CGFloat = 8
        static let spacingY: CGFloat = 6
    }

    // MARK: - Views

    /// Rounded rect showing the priority level colour
    public let priorityBackground = UIView(frame: .zero)

    /// Label inside priority rect showing the priority level text
    public let priorityLabel = UILabel(frame: .zero)

    /// Label next to priority icon
    public let captionLabel = UILabel(frame: .zero)

    // MARK: - Setup

    override public func commonInit() {
        super.commonInit()

        priorityBackground.layer.cornerRadius = 2
        priorityBackground.layer.borderWidth = 1
        priorityBackground.backgroundColor = .green
        priorityBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(priorityBackground)

        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityBackground.addSubview(priorityLabel)

        captionLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        NSLayoutConstraint.activate([
            priorityBackground.widthAnchor.constraint(equalToConstant: PriorityConstants.width),
            priorityBackground.heightAnchor.constraint(equalToConstant: PriorityConstants.height),

            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: PriorityConstants.textMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: PriorityConstants.textMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -PriorityConstants.textMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -PriorityConstants.textMargin),
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // We need to manually frame here due to how CollectionViewFormSubtitleCell works, eek!
        var priorityFrame = CGRect(x: titleLabel.frame.origin.x,
                                   y: subtitleLabel.frame.maxY + PriorityConstants.spacingY,
                                   width: PriorityConstants.width,
                                   height: PriorityConstants.height)

        var captionOrigin = CGPoint(x: priorityFrame.maxX + PriorityConstants.spacingX, y: priorityFrame.origin.y)

        // Remove priority icon if no text
        if let priorityText = priorityLabel.text, priorityText.isEmpty {
            captionOrigin = priorityFrame.origin
            priorityFrame = .zero
        }

        let captionFrame = CGRect(x: captionOrigin.x,
                                  y: captionOrigin.y,
                                  width: contentView.frame.width - captionOrigin.x,
                                  height: PriorityConstants.height)

        priorityBackground.frame = priorityFrame
        captionLabel.frame = captionFrame

        // Update accessory view to keep centered
        if let accessoryView = accessoryView {
            let offsetY = (priorityFrame.height + PriorityConstants.spacingY) / 2
            accessoryView.frame = accessoryView.frame.offsetBy(dx: 0, dy: offsetY)
        }
    }

    public func configurePriority(color priorityColor: UIColor, priorityText: String, priorityFilled: Bool) {
        priorityLabel.text = priorityText

        // Set background color or border color depending on whether filled
        if priorityFilled {
            priorityBackground.backgroundColor = priorityColor
            priorityBackground.layer.borderColor = UIColor.clear.cgColor
            priorityLabel.textColor = .black
        } else {
            priorityBackground.backgroundColor = .clear
            priorityBackground.layer.borderColor = priorityColor.cgColor
            priorityLabel.textColor = priorityColor
        }
    }
}
