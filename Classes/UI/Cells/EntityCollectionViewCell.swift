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
/// `EntityCollectionViewCell` supports displaying cells in three styles: "hero", "detail",
/// and `Thumbnail`.
///
/// The "hero" appearance focuses on the photo/placeholder icon, and shows detail text
/// labels below the context. The "detail" appearance shows the icon at the leading edge,
/// with detail trailing behind. The "thumbnail" shows only the thumbnail.
///
/// EntityCollectionViewCell manages updating its own fonts from its trait collection's
/// preferredContentSizeCategory. It is recommended you avoid updating them.
///
/// You should set the content on all labels regardless of the style of the cell. This allows
/// for transitions and for accessibility.
///
/// TODO: Note alert levels & counts as part of the accessibility value.
open class EntityCollectionViewCell: CollectionViewFormCell {
    
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
    open class func minimumContentWidth(forStyle style: Style) -> CGFloat {
        switch style {
        case .hero:      return 182.0
        case .detail:    return 288.0
        case .thumbnail: return 96.0
        }
    }
    
    
    /// Calculates the minimum content height for an `EntityCollectionViewCell` with the specified sizables.
    ///
    /// - Parameters:
    ///   - style:        The style of the cell.
    ///   - title:        The title sizable.
    ///   - subtitle:     The subtitle sizable.
    ///   - detail:       The detail sizable.
    /// - Returns: The minimum content height for an entity cell with the specified sizables.
    open class func minimumContentHeight(forStyle style: Style, title: StringSizable?, subtitle: StringSizable?, detail: StringSizable?, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        let width = EntityCollectionViewCell.minimumContentWidth(forStyle: style)
        
        // Default fonts for each label
        let titleFont    = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        let subtitleFont = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        let detailFont   = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        
        var textHeight: CGFloat = 0
        
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
        textHeight += titleSizing?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0
        
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
        textHeight += subtitleSizing?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0
        
        // Sizing for detail
        var detailSizing = detail?.sizing()
        if detailSizing != nil {
            if detailSizing!.font == nil {
                detailSizing!.font = detailFont
            }
            if detailSizing!.numberOfLines == nil {
                detailSizing!.numberOfLines = 2
            }
        }
        textHeight += detailSizing?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0
        
        switch style {
        case .hero:
            return 173.0 + textHeight
        case .detail:
            return max(128.0, textHeight)
        case .thumbnail:
            return 96.0
        }
    }
    
    
    // MARK: - Public properties
    
    /// The style for this cell. The default is `EntityCollectionViewCell.Style.hero`.
    open var style: Style = .hero {
        didSet {
            if style == oldValue { return }
            
            if let styleConstraints = self.styleConstraints, styleConstraints.isEmpty == false {
                NSLayoutConstraint.deactivate(styleConstraints)
                self.styleConstraints = nil
                setNeedsUpdateConstraints()
            }
            
            let isThumbnail = style == .thumbnail
            titleLabel.isHidden    = isThumbnail || (titleLabel.text?.isEmpty    ?? true)
            subtitleLabel.isHidden = isThumbnail || (subtitleLabel.text?.isEmpty ?? true)
            detailLabel.isHidden   = isThumbnail || (detailLabel.text?.isEmpty   ?? true)
        }
    }
    
    
    /// The thumbnail view for the cell.
    public let thumbnailView = EntityThumbnailView(frame: .zero)
    
    
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
    
    /// The badge count for the entity.
    ///
    /// This configures a badge in the top left corner.
    /// The badge color will match the alertColor, or gray.
    open var badgeCount: UInt = 0 {
        didSet {
            
            if badgeCount == oldValue { return }
            
            badgeView.text = String(describing: badgeCount)
            badgeView.isHidden = badgeCount == 0
            setNeedsLayout()
        }
    }
    
    open var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            badgeView.backgroundColor = borderColor ?? .gray
        }
    }
    
    
    // MARK: - Private properties
    
    private let badgeView = BadgeView(style: .system)
    
    private let textLabelGuide = UILayoutGuide()
    
    private var styleConstraints: [NSLayoutConstraint]?
    
    private var titleToSubtitleConstraint: NSLayoutConstraint!
    
    private var subtitleToDetailConstraint: NSLayoutConstraint!
    
    
    
    // MARK: - Initializers
    
    override open func commonInit() {
        super.commonInit()
        
        separatorStyle = .none

        let contentView    = self.contentView
        let thumbnailView  = self.thumbnailView
        let titleLabel     = self.titleLabel
        let subtitleLabel  = self.subtitleLabel
        let detailLabel    = self.detailLabel
        let badgeView      = self.badgeView
        let sourceLabel    = self.sourceLabel
        let textLabelGuide = self.textLabelGuide

        sourceLabel.layoutMargins = UIEdgeInsets(top: 2.0 + (1.0 / UIScreen.main.scale), left: 6.0, bottom: 2.0, right: 6.0)
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints    = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints   = false
        badgeView.translatesAutoresizingMaskIntoConstraints     = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints   = false
        
        contentView.addSubview(thumbnailView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(badgeView)
        contentView.addSubview(sourceLabel)
        contentView.addLayoutGuide(textLabelGuide)
        
        titleLabel.isHidden    = true
        subtitleLabel.isHidden = true
        detailLabel.isHidden   = true
        
        titleLabel.adjustsFontForContentSizeCategory    = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory   = true
        
        detailLabel.numberOfLines = 2
        
        let footnoteFont   = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        titleLabel.font    = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        subtitleLabel.font = footnoteFont
        detailLabel.font   = footnoteFont
    
        titleToSubtitleConstraint  = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,    attribute: .bottom)
        subtitleToDetailConstraint = NSLayoutConstraint(item: detailLabel,   attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: thumbnailView, attribute: .trailing, constant: -2.0),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: thumbnailView, attribute: .top,      constant: 2.0),
            
            NSLayoutConstraint(item: sourceLabel, attribute: .leading,  relatedBy: .equal,           toItem: thumbnailView, attribute: .leading,  constant: 10.0),
            NSLayoutConstraint(item: sourceLabel, attribute: .bottom,   relatedBy: .equal,           toItem: thumbnailView, attribute: .bottom,   constant: -10.0),
            NSLayoutConstraint(item: sourceLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: thumbnailView, attribute: .trailing, constant: -10.0),
            
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
    
    open override func updateConstraints() {
        if self.styleConstraints?.isEmpty ?? true {
            let styleConstraints: [NSLayoutConstraint]
            
            let contentView = self.contentView
            let contentModeGuide = self.contentModeLayoutGuide
            
            switch style {
            case .hero:
                let width = EntityCollectionViewCell.minimumContentWidth(forStyle: style)
                styleConstraints = [
                    NSLayoutConstraint(item: thumbnailView, attribute: .width,   relatedBy: .equal, toConstant: width),
                    NSLayoutConstraint(item: thumbnailView, attribute: .height,  relatedBy: .equal, toConstant: width),
                    NSLayoutConstraint(item: thumbnailView, attribute: .top,     relatedBy: .equal, toItem: contentView, attribute: .topMargin),
                    NSLayoutConstraint(item: thumbnailView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leading),
                    NSLayoutConstraint(item: thumbnailView, attribute: .centerX, relatedBy: .equal, toItem: contentModeGuide, attribute: .centerX, priority: .almostRequired),
                    
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,  relatedBy: .equal, toItem: thumbnailView, attribute: .leading),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .top,      relatedBy: .equal, toItem: thumbnailView, attribute: .bottom, constant: 9.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .bottom,   relatedBy: .equal, toItem: contentModeGuide, attribute: .bottom),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeGuide, attribute: .trailing),
                ]
            case .detail:
                styleConstraints = [
                    NSLayoutConstraint(item: thumbnailView, attribute: .width,      relatedBy: .equal, toConstant: 128.0),
                    NSLayoutConstraint(item: thumbnailView, attribute: .height,     relatedBy: .equal, toConstant: 128.0),
                    NSLayoutConstraint(item: thumbnailView, attribute: .leading,    relatedBy: .equal, toItem: contentModeGuide, attribute: .leading),
                    NSLayoutConstraint(item: thumbnailView, attribute: .centerY,    relatedBy: .equal, toItem: contentModeGuide, attribute: .centerY, priority: .almostRequired),
                    NSLayoutConstraint(item: thumbnailView, attribute: .top,        relatedBy: .greaterThanOrEqual, toItem: contentModeGuide, attribute: .top),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,   relatedBy: .equal, toItem: thumbnailView, attribute: .trailing, constant: 16.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .centerY,   relatedBy: .equal, toItem: thumbnailView, attribute: .centerY),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing,  relatedBy: .lessThanOrEqual,    toItem: contentModeGuide, attribute: .trailing)
                ]
            case .thumbnail:
                styleConstraints = [
                    NSLayoutConstraint(item: thumbnailView, attribute: .width,   relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: thumbnailView, attribute: .height,  relatedBy: .equal, toConstant: 96.0),
                    NSLayoutConstraint(item: thumbnailView, attribute: .top,     relatedBy: .equal, toItem: contentModeGuide, attribute: .top),
                    NSLayoutConstraint(item: thumbnailView, attribute: .centerY, relatedBy: .equal, toItem: contentModeGuide, attribute: .centerY),
                    NSLayoutConstraint(item: thumbnailView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentModeGuide, attribute: .leading),
                    NSLayoutConstraint(item: thumbnailView, attribute: .centerX, relatedBy: .equal, toItem: contentModeGuide, attribute: .centerX, priority: .almostRequired),
                    
                    NSLayoutConstraint(item: textLabelGuide, attribute: .leading,  relatedBy: .equal, toItem: thumbnailView, attribute: .trailing, constant: 10.0),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .centerY,  relatedBy: .equal, toItem: thumbnailView, attribute: .centerY),
                    NSLayoutConstraint(item: textLabelGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: thumbnailView, attribute: .trailing, constant: 110),
                ]
            }
            
            NSLayoutConstraint.activate(styleConstraints)
            self.styleConstraints = styleConstraints
        }
        
        super.updateConstraints()
    }
    
    
    // MARK: - Change handlers
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            if style == .thumbnail {
                return
            }
            
            let object = object as? NSObject
            
            if object == titleLabel {
                titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
            } else {
                let hasNoSubtitle = subtitleLabel.text?.isEmpty ?? true
                let hasNoDetail   = detailLabel.text?.isEmpty   ?? true
                
                titleToSubtitleConstraint.constant  = hasNoSubtitle && hasNoDetail ? 0.0 : 6.0
                subtitleToDetailConstraint.constant = hasNoDetail || hasNoSubtitle ? 0.0 : 10.0
                
                subtitleLabel.isHidden = hasNoSubtitle
                detailLabel.isHidden   = hasNoDetail
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Accessibility
    
    open override var accessibilityLabel: String? {
        get {
            return super.accessibilityLabel ?? [sourceLabel.text, titleLabel.text, subtitleLabel.text, detailLabel.text].compactMap({$0}).joined(separator: ". ")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
    
}


