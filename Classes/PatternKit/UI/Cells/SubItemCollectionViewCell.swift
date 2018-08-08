//
//  SubItemCollectionViewCell.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class SubItemCollectionViewCell: CollectionViewFormCell {

    // MARK: - Public properties

    public let borderView: UIView = UIView()

    public let imageView: UIImageView = UIImageView(frame: .zero)

    public let titleLabel: UILabel = UILabel(frame: .zero)

    public let detailLabel: UILabel = UILabel(frame: .zero)

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
                if let previousCell = actionButton.superview as? SubItemCollectionViewCell {
                    // Remove button from old cell
                    previousCell.actionButton = nil
                }

                // Add new button and constraints to shorten separator line at beginning of button
                contentView.addSubview(actionButton)
                actionButton.translatesAutoresizingMaskIntoConstraints = false
                actionButton.setContentHuggingPriority(.required, for: .horizontal)
                actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
                NSLayoutConstraint.activate([
                    titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8).withPriority(UILayoutPriority.required),
                    actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                    actionButton.trailingAnchor.constraint(equalTo: safeAreaOrFallbackTrailingAnchor, constant: -20),
                ])
            }
        }
    }


    // MARK: - Private/internal properties

    private let textLayoutGuide = UILayoutGuide()


    // MARK: - Initialization

    override open func commonInit() {
        super.commonInit()

        borderView.layer.cornerRadius = 15
        borderView.layer.masksToBounds = true

        accessibilityTraits |= UIAccessibilityTraitStaticText

        let contentView       = self.contentView
        let titleLabel        = self.titleLabel
        let detailLabel       = self.detailLabel

        borderView.translatesAutoresizingMaskIntoConstraints  = false
        imageView.translatesAutoresizingMaskIntoConstraints   = false
        titleLabel.translatesAutoresizingMaskIntoConstraints  = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory = true

        let traitCollection = self.traitCollection
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        detailLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)

        contentView.addSubview(borderView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)

        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        detailLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)

        customSeparatorInsets = UIEdgeInsets(top: 0.0, left: 88, bottom: 0.0, right: 16)

        NSLayoutConstraint.activate([
            //Border View
            NSLayoutConstraint(item: borderView, attribute: .top,     relatedBy: .equal, toItem: contentView, attribute: .top),
            NSLayoutConstraint(item: borderView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: borderView, attribute: .trailing, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: borderView, attribute: .bottom,   relatedBy: .equal, toItem: contentView, attribute: .bottom),

            //Image View
            NSLayoutConstraint(item: imageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: imageView, attribute: .width,   relatedBy: .equal, toConstant: 48.0),
            NSLayoutConstraint(item: imageView, attribute: .height,  relatedBy: .equal, toConstant: 48.0),

            //Title Label
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal, toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: textLayoutGuide, attribute: .trailing, priority: UILayoutPriority.almostRequired),

            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .equal,             toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, constant: 16.0),

            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),

            //Detail Label
            NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom),
            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .equal, toItem: textLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: detailLabel, attribute: .bottom, relatedBy: .equal, toItem: textLayoutGuide, attribute: .bottom),

        ])
    }

    // MARK: - Overrides

    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return [titleLabel, detailLabel].compactMap({ $0.text }).joined(separator: ", ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    // MARK: - Class sizing methods

    /// Calculates the minimum content height for a cell, considering the text details.
    /// Nil values for title, subtitle and source will give a default height of 48.0.
    ///
    /// - Parameters:
    ///   - title: The title text (useful for multiline sizables).
    ///   - width: The given width for the cell.
    ///   - traitCollection: The trait collection the cell will be displayed in.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: StringSizable?,  detail: StringSizable?, accessorySize: CGSize? = nil, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {

        // Default fonts for each label
        let titleFont    = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        let detailFont   = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)

        var accessoryWidth: CGFloat = 0.0
        if let size = accessorySize {
            accessoryWidth = size.width + CollectionViewFormCell.accessoryContentInset
        }

        // Sizing for title
        var titleSizing = title?.sizing()
        if titleSizing != nil {
            if titleSizing!.font == nil {
                titleSizing!.font = titleFont
            }
            if titleSizing!.numberOfLines == nil {
                titleSizing!.numberOfLines = 1
            }
        }
        let titleHeight = titleSizing?.minimumHeight(inWidth: width - 48 - 16 - accessoryWidth, compatibleWith: traitCollection) ?? 0

        // Sizing for detail
        var detailSizing = detail?.sizing()
        if detailSizing != nil {
            if detailSizing!.font == nil {
                detailSizing!.font = detailFont
            }
            if detailSizing!.numberOfLines == nil {
                detailSizing!.numberOfLines = 1
            }
        }
        let detailHeight = detailSizing?.minimumHeight(inWidth: width - 48 - 16 - accessoryWidth, compatibleWith: traitCollection) ?? 0

        return max(titleHeight + detailHeight + CellTitleSubtitleSeparation, 48.0)
    }

}
