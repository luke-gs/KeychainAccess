//
//  EntityDetailCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1

public class EntityDetailCollectionViewCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    /// The image view for the cell.
    public var imageView: UIImageView { return borderedImageView.imageView }
    
    
    /// The source label.
    public let sourceLabel = RoundedRectLabel(frame: .zero)
    
    
    /// The title label. This should be used for details such as the driver's name,
    /// vehicle's registration, etc.
    public let titleLabel = UILabel(frame: .zero)
    

    /// The subtitle label. This should be used for ancillery entity details.
    public let subtitleLabel = UILabel(frame: .zero)
    
    
    /// The description label. This should be a description of the entity, attributes etc.
    public let descriptionLabel = UILabel(frame: .zero)
    
    
    /// The alert color for the entity.
    public var alertColor: UIColor? {
        get { return borderedImageView.borderColor }
        set { borderedImageView.borderColor = newValue }
    }
    
    
    /// A button for selecting/entering additional details.
    public var additionalDetailsButton = UIButton(type: .system)
    
    
    /// The additional description action method.
    ///
    /// It is recommended that you set this handler, rather than becoming
    /// a target action receiver directly.
    public var additionalDetailsButtonActionHandler: ((EntityDetailCollectionViewCell) -> Void)?
    
    
    
    // MARK: - Private properties
    
    private let borderedImageView = BorderedImageView(frame: .zero)
    
    private var compactWidthConstraints: [NSLayoutConstraint] = []
    
    private var regularWidthConstraints: [NSLayoutConstraint] = []
    
    private var sourceToTitleConstraint: NSLayoutConstraint!
    
    private var titleToSubtitleConstraint: NSLayoutConstraint!
    
    private var subtitleToDescriptionConstraint: NSLayoutConstraint!
    
    private var descriptionToMoreConstraint: NSLayoutConstraint!
    
    
    
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
        sourceLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.isHidden = true
        
        titleLabel.font  = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.isHidden = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.isHidden = true
        
        additionalDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        additionalDetailsButton.titleLabel?.font = .systemFont(ofSize: 11, weight: UIFontWeightMedium)
        
        borderedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        let labelLayoutGuide = UILayoutGuide()
        
        let contentView = self.contentView
        contentView.addSubview(borderedImageView)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(additionalDetailsButton)
        contentView.addLayoutGuide(labelLayoutGuide)
        
        sourceToTitleConstraint   = NSLayoutConstraint(item: titleLabel,    attribute: .top, relatedBy: .equal, toItem: sourceLabel, attribute: .bottom) // 6.0 with content
        titleToSubtitleConstraint = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,  attribute: .bottom) // 3.0 with content
        subtitleToDescriptionConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom) // 16.0 with content
        descriptionToMoreConstraint = NSLayoutConstraint(item: additionalDetailsButton, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom) // 16.0 with content
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: sourceLabel, attribute: .leading,  relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: sourceLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: labelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: sourceLabel, attribute: .top, relatedBy: .equal, toItem: labelLayoutGuide, attribute: .top),
            sourceToTitleConstraint,
            
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: labelLayoutGuide, attribute: .trailing),
            
            titleToSubtitleConstraint,
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: labelLayoutGuide, attribute: .trailing),
            
            subtitleToDescriptionConstraint,
            NSLayoutConstraint(item: descriptionLabel, attribute: .leading,  relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: descriptionLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: labelLayoutGuide, attribute: .trailing),
            
            descriptionToMoreConstraint,
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .leading,  relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: labelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .bottom,   relatedBy: .equal,           toItem: labelLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: labelLayoutGuide, attribute: .centerY,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .centerY),
            NSLayoutConstraint(item: labelLayoutGuide, attribute: .height,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .height),
            NSLayoutConstraint(item: labelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
        ])
        
        regularWidthConstraints = [
            NSLayoutConstraint(item: borderedImageView, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: borderedImageView, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .height),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,   relatedBy: .equal,           toItem: borderedImageView, attribute: .width),
            NSLayoutConstraint(item: borderedImageView, attribute: .width,    relatedBy: .equal,           toConstant: 202),
            
            NSLayoutConstraint(item: labelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 15.0)
        ]
        
        compactWidthConstraints = [
            NSLayoutConstraint(item: labelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading)
        ]
        
        additionalDetailsButton.addTarget(self, action: #selector(additionalDescriptionsButtonDidSelect), for: .touchUpInside)
        
        if traitCollection.horizontalSizeClass == .compact {
            borderedImageView.wantsRoundedCorners = false
            sourceLabel.isHidden       = true
            borderedImageView.isHidden = true
            NSLayoutConstraint.activate(compactWidthConstraints)
        } else {
            NSLayoutConstraint.activate(regularWidthConstraints)
        }
        
        sourceLabel.addObserver(self,      forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        titleLabel.addObserver(self,       forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        subtitleLabel.addObserver(self,    forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        descriptionLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        additionalDetailsButton.titleLabel?.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
    }
    
    deinit {
        sourceLabel.removeObserver(self,      forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        titleLabel.removeObserver(self,       forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        subtitleLabel.removeObserver(self,    forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        descriptionLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
        additionalDetailsButton.titleLabel?.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &kvoContext)
    }
    
    
    // MARK: - Action methods
    
    @objc private func additionalDescriptionsButtonDidSelect() {
        additionalDetailsButtonActionHandler?(self)
    }
    
    
    // MARK: - Overrides
    
    open override var bounds: CGRect {
        didSet {
            if bounds.width !=~ oldValue.width {
                let maxTextWidth = bounds.insetBy(layoutMargins).width - (traitCollection.horizontalSizeClass == .compact ? 0.0 : 217.0)
                titleLabel.preferredMaxLayoutWidth = maxTextWidth
                descriptionLabel.preferredMaxLayoutWidth = maxTextWidth
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.width !=~ oldValue.width {
                let maxTextWidth = bounds.insetBy(layoutMargins).width - (traitCollection.horizontalSizeClass == .compact ? 0.0 : 217.0)
                titleLabel.preferredMaxLayoutWidth = maxTextWidth
                descriptionLabel.preferredMaxLayoutWidth = maxTextWidth
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            let layoutMargins = self.layoutMargins
            if layoutMargins.left !=~ oldValue.left || layoutMargins.right !=~ oldValue.right {
                let maxTextWidth = bounds.insetBy(layoutMargins).width - (traitCollection.horizontalSizeClass == .compact ? 0.0 : 217.0)
                titleLabel.preferredMaxLayoutWidth = maxTextWidth
                descriptionLabel.preferredMaxLayoutWidth = maxTextWidth
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        if (previousTraitCollection?.horizontalSizeClass == .compact) != isCompact {
            borderedImageView.wantsRoundedCorners = isCompact == false
            borderedImageView.isHidden = isCompact
            
            if isCompact {
                NSLayoutConstraint.deactivate(regularWidthConstraints)
                NSLayoutConstraint.activate(compactWidthConstraints)
            } else {
                NSLayoutConstraint.deactivate(compactWidthConstraints)
                NSLayoutConstraint.activate(regularWidthConstraints)
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            let hasSource          = sourceLabel.text?.isEmpty      ?? true == false
            let hasTitle           = titleLabel.text?.isEmpty       ?? true == false
            let hasSubtitle        = subtitleLabel.text?.isEmpty    ?? true == false
            let hasDescription     = descriptionLabel.text?.isEmpty ?? true == false
            let hasMoreDescription = additionalDetailsButton.titleLabel?.text?.isEmpty ?? true == false
            
            if let object = object as? NSObject {
                switch object {
                case sourceLabel:
                    sourceLabel.isHidden                     = hasSource == false
                    sourceToTitleConstraint.constant         = hasSource ? 6.0 : 0.0
                case titleLabel:
                    titleLabel.isHidden                      = hasTitle == false
                    titleToSubtitleConstraint.constant       = hasTitle && hasSubtitle ? 3.0 : 0.0
                case subtitleLabel:
                    subtitleLabel.isHidden                   = hasSubtitle == false
                    titleToSubtitleConstraint.constant       = hasTitle && hasSubtitle ? 3.0 : 0.0
                    subtitleToDescriptionConstraint.constant = (hasTitle || hasSubtitle) && hasDescription ? 16.0 : 0.0
                case descriptionLabel:
                    descriptionLabel.isHidden                = hasDescription == false
                    subtitleToDescriptionConstraint.constant = (hasTitle || hasSubtitle) && hasDescription ? 16.0 : 0.0
                default:
                    descriptionToMoreConstraint.constant     = (hasTitle || hasSubtitle || hasDescription) && hasMoreDescription ? 16.0 : 0.0
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    internal override func applyStandardFonts() {
        super.applyStandardFonts()
        
        if #available(iOS 10, *) {
            subtitleLabel.font    = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            descriptionLabel.font = .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
        } else {
            subtitleLabel.font    = .preferredFont(forTextStyle: .subheadline)
            descriptionLabel.font = .preferredFont(forTextStyle: .headline)
        }
    }
    
    
    // MARK: - Siing
    
    public class func minimumContentHeight(withTitle title: String?, subtitle: String?, description: String?, additionalDetails: String?, source: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let displayScale = traitCollection.currentDisplayScale
        
        var textHeight: CGFloat
        
        let hasTitle:       Bool
        let hasSubtitle:    Bool
        let hasDescription: Bool
        
        let maxTextSize = CGSize(width: (isCompact ? width : width - 217.0).floored(toScale: displayScale), height: CGFloat.greatestFiniteMagnitude)
        
        if let title = title as NSString?, title.length > 0 {
            let titleFont = UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            textHeight = title.boundingRect(with: maxTextSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: titleFont], context: nil).height.ceiled(toScale: displayScale)
            hasTitle = true
        } else {
            textHeight = 0.0
            hasTitle = false
        }
        
        if subtitle?.isEmpty ?? true {
            hasSubtitle = false
        } else {
            let subtitleFont: UIFont
            if #available(iOS 10, *) {
                subtitleFont = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
            } else {
                subtitleFont = .preferredFont(forTextStyle: .subheadline)
            }
            hasSubtitle = true
            if hasTitle { textHeight += 3.0 }
            textHeight += subtitleFont.lineHeight.ceiled(toScale: displayScale)
        }
        
        if let description = description as NSString?, description.length > 0 {
            let descriptionFont: UIFont
            if #available(iOS 10, *) {
                descriptionFont = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            } else {
                descriptionFont = .preferredFont(forTextStyle: .headline)
            }
            hasDescription = true
            if hasTitle || hasSubtitle { textHeight += 16.0 }
            
            textHeight += description.boundingRect(with: maxTextSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: descriptionFont], context: nil).height.ceiled(toScale: displayScale)
        } else {
            hasDescription = false
        }
        
        if additionalDetails?.isEmpty ?? true == false {
            if hasDescription || hasSubtitle || hasTitle { textHeight += 16.0 }
            textHeight += UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium).lineHeight.ceiled(toScale: displayScale) + 13.0
        }
        
        if source?.isEmpty ?? true == false {
            textHeight += UIFont.systemFont(ofSize: 11.0, weight: UIFontWeightBold).lineHeight.ceiled(toScale: displayScale) + 11.0
        }
        
        return isCompact ? textHeight : max(textHeight, 202.0) // 202 is the height for the image view in non-compact mode.
    }
    
}
