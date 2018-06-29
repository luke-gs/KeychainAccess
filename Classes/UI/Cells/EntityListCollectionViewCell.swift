//
//  EntityListCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 6/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

open class EntityListCollectionViewCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    public let thumbnailView: EntityThumbnailView = EntityThumbnailView(frame: .zero)
    
    public let sourceLabel: RoundedRectLabel = RoundedRectLabel(frame: .zero)

    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    public let subtitleLabel: UILabel = UILabel(frame: .zero)

    public let detailLabel: UILabel = UILabel(frame: .zero)

    open var actionCount: UInt = 0 {
        didSet {
            
            if actionCount == oldValue { return }
            
            badgeView.text = String(describing: actionCount)
            badgeView.isHidden = actionCount == 0
            setNeedsLayout()
        }
    }
    
    open var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            badgeView.backgroundColor = borderColor ?? .gray
        }
    }
    
    
    // MARK: - Private/internal properties
    
    private let textLayoutGuide = UILayoutGuide()
    
    private var sourceSubtitleHorizontalConstraint: NSLayoutConstraint!
    
    private let badgeView = BadgeView(style: .system)
    
    
    // MARK: - Initialization
    
    override open func commonInit() {
        super.commonInit()
        
        accessibilityTraits |= UIAccessibilityTraitStaticText

        let contentView       = self.contentView
        let borderedImageView = self.thumbnailView
        let sourceLabel       = self.sourceLabel
        let titleLabel        = self.titleLabel
        let subtitleLabel     = self.subtitleLabel
        let detailLabel       = self.detailLabel

        sourceLabel.layoutMargins = UIEdgeInsets(top: 2.0 + (1.0 / UIScreen.main.scale), left: 6.0, bottom: 2.0, right: 6.0)

        badgeView.translatesAutoresizingMaskIntoConstraints         = false
        borderedImageView.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints       = false
        titleLabel.translatesAutoresizingMaskIntoConstraints        = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints     = false
        detailLabel.translatesAutoresizingMaskIntoConstraints     = false

        sourceLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory = true

        let traitCollection = self.traitCollection
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        detailLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)

        contentView.addSubview(subtitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(borderedImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(detailLabel)

        let textLayoutGuide        = self.textLayoutGuide
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        contentView.addLayoutGuide(textLayoutGuide)
        
        sourceLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        sourceLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        sourceLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        subtitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        detailLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)

        sourceSubtitleHorizontalConstraint = NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal, toItem: sourceLabel, attribute: .trailing, constant: 8.0)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: borderedImageView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: borderedImageView, attribute: .centerY, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: borderedImageView, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: borderedImageView, attribute: .width,   relatedBy: .equal, toConstant: 48.0),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,  relatedBy: .equal, toConstant: 48.0),
            
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: -2.0),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: borderedImageView, attribute: .top,      constant: 2.0),
            
            NSLayoutConstraint(item: sourceLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: sourceLabel, attribute: .top,     relatedBy: .equal, toItem: subtitleLabel,      attribute: .top),
            
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal,           toItem: textLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal,           toItem: textLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .equal, toItem: textLayoutGuide, attribute: .trailing),

            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: titleLabel, attribute: .bottom, constant: CellTitleSubtitleSeparation),
            NSLayoutConstraint(item: sourceLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: titleLabel, attribute: .bottom, constant: CellTitleSubtitleSeparation),
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: textLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .centerY, relatedBy: .equal,              toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .trailing, relatedBy: .equal,             toItem: contentModeLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 16.0),
            
            NSLayoutConstraint(item: borderedImageView, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),
            NSLayoutConstraint(item: textLayoutGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top, priority: UILayoutPriority.defaultLow),

            //Detail Label
            NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: subtitleLabel, attribute: .bottom, constant: CellSubtitleDetailSeparation),

            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .equal, toItem: textLayoutGuide, attribute: .trailing),

            NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: textLayoutGuide, attribute: .leading),

            NSLayoutConstraint(item: detailLabel, attribute: .bottom, relatedBy: .equal, toItem: textLayoutGuide, attribute: .bottom),

            sourceSubtitleHorizontalConstraint
            ])
        
        sourceLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        sourceLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    deinit {
        sourceLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        sourceLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &kvoContext)
    }
    
    
    // MARK: - Overrides
    
    open override var accessibilityLabel: String? {
        get {
            if let setValue = super.accessibilityLabel {
                return setValue
            }
            return [titleLabel, subtitleLabel, detailLabel].compactMap({ $0.text }).joined(separator: ", ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            // Drop the source title separation if the source label has no text.
            sourceSubtitleHorizontalConstraint.constant = sourceLabel.text?.isEmpty ?? true ? 0.0 : 8.0
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for a cell, considering the text details.
    /// Nil values for title, subtitle and source will give a default height of 48.0.
    ///
    /// - Parameters:
    ///   - title: The title text (useful for multiline sizables).
    ///   - subtitle: The subtitle text (useful for multiline sizables).
    ///   - source: The source text  (useful for multiline sizables).
    ///   - width: The given width for the cell.
    ///   - traitCollection: The trait collection the cell will be displayed in.
    /// - Returns: The minumum content height for the cell.
    open class func minimumContentHeight(withTitle title: StringSizable?, subtitle: StringSizable?,  detail: StringSizable?, source: String?, accessorySize: CGSize? = nil, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        // Default fonts for each label
        let titleFont    = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        let subtitleFont = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        let detailFont   = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        let sourceFont   = UIFont.preferredFont(forTextStyle: .body,     compatibleWith: traitCollection)
        
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
        
        // Get width of source label
        var sourceWidth: CGFloat = 0.0
        if let source = source {
            sourceWidth = source.sizing(withNumberOfLines: 1, font: sourceFont).minimumWidth(compatibleWith: traitCollection) + 10 + 10 + 8
        }

        // Sizing for subtitle
        var subtitleSizing = subtitle?.sizing()
        if subtitleSizing != nil {
            if subtitleSizing!.font == nil {
                subtitleSizing!.font = subtitleFont
            }
            if subtitleSizing!.numberOfLines == nil {
                subtitleSizing!.numberOfLines = 1
            }
        }

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
        let subtitleHeight = subtitleSizing?.minimumHeight(inWidth: width - 48 - 16 - sourceWidth - accessoryWidth, compatibleWith: traitCollection) ?? 0
        let detailHeight = detailSizing?.minimumHeight(inWidth: width - 48 - 16 - accessoryWidth, compatibleWith: traitCollection) ?? 0

        return max(titleHeight + subtitleHeight + detailHeight + CellTitleSubtitleSeparation, 48.0)
    }
    
}
