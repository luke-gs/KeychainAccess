//
//  EntityCollectionViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var textContext = 1

/// `EntityCollectionViewCell` is a cell for displaying MPOL entities with a standardized
/// MPOL branding and appearance.
///
/// `EntityCollectionViewCell supports displaying cells in two styles: "hero", and "detail".
/// The "hero" appearance focuses on the photo/placeholder icon, and shows detail text
/// labels below the context. The "detail" appearance shows the icon at the leading edge,
/// with detail trailing behind.
///
/// EntityCollectionViewCell manages updating its own fonts from its trait collection's
/// preferredContentSizeCategory. It is recommended you avoid updating them.
public class EntityCollectionViewCell: CollectionViewFormCell {
    
    /// The style types for an `EntityCollectionViewCell`. These include
    /// `.hero` and `.detail`.
    public enum Style: Int {
        /// The Hero style. This style emphasizes the icon.
        case hero
        
        /// The Detail style. This style emphasizes the icon and detail equally.
        case detail
        
        /// The Thumbnail style. This style hides the labels to simplify and avoid clutter.
        case thumbnail
    }
    
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum width for an `EntityCollectionViewCell` with a specified style.
    ///
    /// - Parameter style: The style for the cell.
    /// - Returns: The minimum content width for the cell
    public class func minimumContentWidth(forStyle style: Style) -> CGFloat {
        switch style {
        case .hero:      return 182.0
        case .detail:    return 250.0
        case .thumbnail: return 96.0
        }
    }
    
    
    /// Calculates the minimum content height for an `EntityCollectionViewCell` with default font settings
    /// when contained within a specified trait collection.
    ///
    /// - Parameters:
    ///   - style:           The style of the cell.
    ///   - traitCollection: The trait collection sizing for.
    /// - Returns: The minimum content height for the entity cell with default settings.
    public class func minimumContentHeight(forStyle style: Style, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        switch style {
        case .hero:
            let titleFont: UIFont
            let footnoteFont: UIFont
            
            if #available(iOS 10, *) {
                titleFont    = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
                footnoteFont = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
            } else {
                titleFont    = .preferredFont(forTextStyle: .headline)
                footnoteFont = .preferredFont(forTextStyle: .footnote)
            }
            
            return minimumContentHeight(forStyle: style, withTitleFont: titleFont, subtitleFont: footnoteFont, detailFont: footnoteFont)
        case .detail, .thumbnail:
            return 96.0
        }
    }
    
    
    /// Calculates the minimum content height for an `EntityCollectionViewCell` with the specified fonts.
    ///
    /// It is recommended you use the `minimumContentHeight(forStyle:compatibleWith:)` method to calculate
    /// the default height for cells.
    ///
    /// - Parameters:
    ///   - style:        The style of the cell.
    ///   - titleFont:    The font for the title label.
    ///   - subtitleFont: The font for the subtitle label.
    ///   - detailFont:   The font for the detail label.
    /// - Returns: The minimum content height for an entity cell with the specified fonts.
    public class func minimumContentHeight(forStyle style: Style, withTitleFont titleFont: UIFont, subtitleFont: UIFont, detailFont: UIFont) -> CGFloat {
        switch style {
        case .hero:
            let scale = UIScreen.main.scale
            let heightOfFonts =  titleFont.lineHeight.ceiled(toScale: scale) + subtitleFont.lineHeight.ceiled(toScale: scale) + detailFont.lineHeight.ceiled(toScale: scale)
            return 173.0 + heightOfFonts
        case .detail, .thumbnail:
            return 96.0
        }
    }

    

    
    
    // MARK: - Public properties
    
    /// The style for this cell. The default is `EntityCollectionViewCell.Style.hero`.
    public var style: Style = .hero {
        didSet {
            if style == oldValue { return }
            
            if let styleConstraints = self.styleConstraints, styleConstraints.isEmpty == false {
                NSLayoutConstraint.deactivate(styleConstraints)
                self.styleConstraints = nil
                setNeedsUpdateConstraints()
            }
            
            let isThumbnail = style == .thumbnail
            titleLabel.isHidden    = isThumbnail
            subtitleLabel.isHidden = isThumbnail
            detailLabel.isHidden   = isThumbnail
        }
    }
    
    
    /// The image view for the cell.
    public var imageView: UIImageView { return borderedImageView.imageView }
    
    
    /// The title label. This should be used for details such as the driver's name,
    /// vehicle's registration, etc.
    public let titleLabel = UILabel(frame: .zero)
    
    
    /// The subtitle label. This should be used for ancillery entity details.
    public let subtitleLabel = UILabel(frame: .zero)
    
    
    /// The detail label. This should be any secondary details.
    public let detailLabel = UILabel(frame: .zero)
    
    
    /// The source label.
    ///
    /// This label is positioned over the image view's bottom left corner, and
    /// indicates the data source the entity was fetched from.
    public let sourceLabel = RoundedRectLabel(frame: .zero)
    
    
    /// The alert count for the entity.
    ///
    /// This configures a badge in the top left corner.
    /// The badge color will match the alertColor, or gray.
    public var alertCount: UInt = 0 {
        didSet {
            if alertCount == oldValue { return }
            
            badgeView.text = String(describing: alertCount)
            setNeedsLayout()
        }
    }
    
    
    /// The alert color for the entity.
    ///
    /// This color is used for the alert badge, and when non-`nil` applies a colored
    /// border around the image.
    public var alertColor: UIColor? {
        didSet {
            if alertColor == oldValue { return }
            
            badgeView.backgroundColor = alertColor ?? .gray
            borderedImageView.borderColor = alertColor
        }
    }
    
    
    // MARK: - Private properties
    
    private let borderedImageView = BorderedImageView(frame: .zero)
    
    private let badgeView = BadgeView(style: .system)
    
    private let contentBackingView = UIView(frame: .zero)
    
    private let textLabelGuide = UILayoutGuide()
    
    private var styleConstraints: [NSLayoutConstraint]?
    
    private var titleToSubtitleConstraint: NSLayoutConstraint!
    
    private var subtitleToDetailConstraint: NSLayoutConstraint!
    
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        separatorStyle = .none
        
        let backingView      = self.contentBackingView
        let borderImageView  = self.borderedImageView
        let titleLabel       = self.titleLabel
        let subtitleLabel    = self.subtitleLabel
        let detailLabel      = self.detailLabel
        let badgeView        = self.badgeView
        let sourceLabel      = self.sourceLabel
        let textLabelGuide   = self.textLabelGuide
        
        backingView.translatesAutoresizingMaskIntoConstraints     = false
        borderImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints      = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints   = false
        detailLabel.translatesAutoresizingMaskIntoConstraints     = false
        badgeView.translatesAutoresizingMaskIntoConstraints       = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints     = false
        
        backingView.addSubview(borderImageView)
        backingView.addSubview(titleLabel)
        backingView.addSubview(subtitleLabel)
        backingView.addSubview(detailLabel)
        backingView.addSubview(badgeView)
        backingView.addSubview(sourceLabel)
        backingView.addLayoutGuide(textLabelGuide)
        contentView.addSubview(backingView)
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        detailLabel.isHidden   = true
        
        titleToSubtitleConstraint  = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,    attribute: .bottom)
        subtitleToDetailConstraint = NSLayoutConstraint(item: detailLabel,   attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: borderImageView, attribute: .leading,  relatedBy: .equal,           toItem: backingView, attribute: .leading),
            NSLayoutConstraint(item: borderImageView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: backingView, attribute: .trailing, priority: UILayoutPriorityRequired - 1),
            NSLayoutConstraint(item: borderImageView, attribute: .bottom,   relatedBy: .lessThanOrEqual, toItem: backingView, attribute: .bottom, priority: UILayoutPriorityRequired - 1),
            
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: borderImageView, attribute: .trailing, constant: -2.0),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: borderImageView, attribute: .top,      constant: 2.0),
            
            NSLayoutConstraint(item: sourceLabel, attribute: .leading,  relatedBy: .equal,           toItem: borderImageView, attribute: .leading,  constant: 6.0),
            NSLayoutConstraint(item: sourceLabel, attribute: .bottom,   relatedBy: .equal,           toItem: borderImageView, attribute: .bottom,   constant: -6.0),
            NSLayoutConstraint(item: sourceLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: borderImageView, attribute: .trailing, constant: -6.0),
            
            NSLayoutConstraint(item: textLabelGuide, attribute: .bottom,   relatedBy: .lessThanOrEqual, toItem: backingView, attribute: .bottom),
            
            NSLayoutConstraint(item: titleLabel,    attribute: .leading,  relatedBy: .equal,           toItem: textLabelGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: textLabelGuide, attribute: .leading),
            NSLayoutConstraint(item: detailLabel,   attribute: .leading,  relatedBy: .equal,           toItem: textLabelGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel,    attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLabelGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLabelGuide, attribute: .trailing),
            NSLayoutConstraint(item: detailLabel,   attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: textLabelGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: titleLabel,  attribute: .top,    relatedBy: .equal, toItem: textLabelGuide, attribute: .top),
            NSLayoutConstraint(item: detailLabel, attribute: .bottom, relatedBy: .equal, toItem: textLabelGuide, attribute: .bottom),
            
            titleToSubtitleConstraint, subtitleToDetailConstraint
        ])
        
        badgeView.backgroundColor = .gray
        backingView.layer.shouldRasterize = true
        backingView.layer.rasterizationScale = UIScreen.main.scale
        
        let textKey = #keyPath(UILabel.text)
        titleLabel.addObserver(self,    forKeyPath: textKey, context: &textContext)
        subtitleLabel.addObserver(self, forKeyPath: textKey, context: &textContext)
        detailLabel.addObserver(self,   forKeyPath: textKey, context: &textContext)
    }
    
    deinit {
        let textKey = #keyPath(UILabel.text)
        titleLabel.removeObserver(self,    forKeyPath: textKey, context: &textContext)
        subtitleLabel.removeObserver(self, forKeyPath: textKey, context: &textContext)
        detailLabel.removeObserver(self,   forKeyPath: textKey, context: &textContext)
    }
    

    // MARK: - Layout methods
    
    public override func updateConstraints() {
        if self.styleConstraints?.isEmpty ?? true {
            let styleConstraints: [NSLayoutConstraint]
            
            let contentView        = self.contentView
            let contentBackingView = self.contentBackingView
            
            switch style {
            case .hero:
                styleConstraints = [
                    NSLayoutConstraint(item: contentBackingView, attribute: .top,      relatedBy: .equal,           toItem: contentView, attribute: .topMargin),
                    NSLayoutConstraint(item: contentBackingView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
                    
                    NSLayoutConstraint(item: borderedImageView, attribute: .width,   relatedBy: .equal, toConstant: 184.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .height,  relatedBy: .equal, toConstant: 160.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .top,     relatedBy: .equal, toItem: contentBackingView, attribute: .top),
                    NSLayoutConstraint(item: borderedImageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerXWithinMargins),
                    
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,  relatedBy: .equal, toItem: borderedImageView, attribute: .leading),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .top,      relatedBy: .equal, toItem: borderedImageView, attribute: .bottom, constant: 9.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentBackingView, attribute: .trailing)
                ]
            case .detail:
                styleConstraints = [
                    NSLayoutConstraint(item: contentBackingView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins),
                    NSLayoutConstraint(item: contentBackingView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
                    NSLayoutConstraint(item: contentBackingView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
                    
                    NSLayoutConstraint(item: borderedImageView, attribute: .width,   relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .height,  relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .centerY, relatedBy: .equal, toItem: contentBackingView, attribute: .centerY),
                    
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,  relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 10.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .centerY,  relatedBy: .equal, toItem: contentBackingView, attribute: .centerY),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentBackingView, attribute: .trailing),
                ]
            case .thumbnail:
                styleConstraints = [
                    NSLayoutConstraint(item: contentBackingView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins),
                    NSLayoutConstraint(item: contentBackingView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
                    NSLayoutConstraint(item: contentBackingView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailingMargin),
                    
                    NSLayoutConstraint(item: borderedImageView, attribute: .width,   relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .height,  relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: borderedImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins),
                    
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,  relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 10.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .centerY,  relatedBy: .equal, toItem: contentBackingView, attribute: .centerY),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: borderedImageView, attribute: .trailing, constant: 110),
                ]
            }
            
            NSLayoutConstraint.activate(styleConstraints)
            self.styleConstraints = styleConstraints
        }
        
        super.updateConstraints()
    }
    
    
    // MARK: - Change handlers
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentBackingView.layer.rasterizationScale = traitCollection.currentDisplayScale
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            let object = object as? NSObject
            
            if object == titleLabel {
                titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
            } else {
                let hasNoSubtitle = subtitleLabel.text?.isEmpty ?? true
                let hasNoDetail   = detailLabel.text?.isEmpty   ?? true
                
                titleToSubtitleConstraint.constant  = hasNoSubtitle && hasNoDetail ? 0.0 : 2.0
                subtitleToDetailConstraint.constant = hasNoDetail || hasNoSubtitle ? 0.0 : 2.0
                
                subtitleLabel.isHidden = hasNoSubtitle
                detailLabel.isHidden   = hasNoDetail
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        let titleFont: UIFont
        let footnoteFont: UIFont
        
        if #available(iOS 10, *) {
            let traitCollection = self.traitCollection
            titleFont    = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            footnoteFont = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        } else {
            titleFont    = .preferredFont(forTextStyle: .headline)
            footnoteFont = .preferredFont(forTextStyle: .footnote)
        }
        
        titleLabel.font    = titleFont
        subtitleLabel.font = footnoteFont
        detailLabel.font   = footnoteFont
    }
    
    
    
}


