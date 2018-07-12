//
//  CollectionViewFormLabelCell.swift
//  MPOLKit
//
//  Created by Kyle May on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Collection view cell for a label
open class CollectionViewFormLargeTextLabelCell: UICollectionReusableView, DefaultReusable {
    public static let defaultFont = UIFont.systemFont(ofSize: 22, weight: .bold)
    public let titleLabel = UILabel()
    public let separatorView = UIView()

    /// Optional action button to be displayed at right of header
    public var actionButton: UIButton? {
        didSet {
            guard actionButton != oldValue else { return }
            if let oldValue = oldValue {
                // Remove old button and associated constraints
                oldValue.removeFromSuperview()
            }
            if let actionButton = actionButton {
                // Make sure action button is not being used in another cell due to cell reuse
                // Ideally we would just clear this in prepareForReuse(), but collection view
                // sometimes configures a new cell before calling that method on old one :(
                if let previousCell = actionButton.superview as? CollectionViewFormLargeTextLabelCell {
                    // Remove button from old cell
                    previousCell.actionButton = nil
                }

                // Add new button and constaints to shorten separator line at beginning of button
                addSubview(actionButton)
                actionButton.translatesAutoresizingMaskIntoConstraints = false
                actionButton.setContentHuggingPriority(.required, for: .horizontal)
                actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
                NSLayoutConstraint.activate([
                    actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
                    actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                    actionButton.trailingAnchor.constraint(equalTo: safeAreaOrFallbackTrailingAnchor).withPriority(.required),
                ])
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = CollectionViewFormLargeTextLabelCell.defaultFont
        titleLabel.textColor = .primaryGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        separatorView.backgroundColor = iOSStandardSeparatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).withPriority(.almostRequired),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor),

            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ])
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
