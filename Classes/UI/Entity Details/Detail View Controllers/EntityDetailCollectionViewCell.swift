//
//  EntityDetailCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var kvoContext = 1
private let compactWidth: CGFloat = 404.0

open class EntityDetailCollectionViewCell: CollectionViewFormCell {
    
    // MARK: - Public properties
    
    /// The thumbnail view for the cell.
    open var thumbnailView = EntityThumbnailView(frame: .zero)
    
    
    /// The source label.
    open let sourceLabel = RoundedRectLabel(frame: .zero)
    
    
    /// The title label. This should be used for details such as the driver's name,
    /// vehicle's registration, etc.
    open let titleLabel = UILabel(frame: .zero)
    

    /// The subtitle label. This should be used for ancillery entity details.
    open let subtitleLabel = UILabel(frame: .zero)
    
    
    /// The description label. This should be a description of the entity, attributes etc.
    open let descriptionLabel = UILabel(frame: .zero)
    
    open var isDescriptionPlaceholder: Bool = false {
        didSet {
            let textStyle: UIFontTextStyle = isDescriptionPlaceholder ? .subheadline : .headline
            descriptionLabel.font = .preferredFont(forTextStyle: textStyle, compatibleWith: traitCollection)
        }
    }
    
    
    /// A button for selecting/entering additional details.
    open var additionalDetailsButton = UIButton(type: .system)
    
    
    /// The additional description action method.
    ///
    /// It is recommended that you set this handler, rather than becoming
    /// a target action receiver directly.
    open var additionalDetailsButtonActionHandler: ((EntityDetailCollectionViewCell) -> Void)?
    
    
    
    // MARK: - Private properties
    
    private var compactWidthConstraints: [NSLayoutConstraint] = []
    
    private var regularWidthConstraints: [NSLayoutConstraint] = []
    
    private var sourceToTitleConstraint: NSLayoutConstraint!
    
    private var titleToSubtitleConstraint: NSLayoutConstraint!
    
    private var subtitleToDescriptionConstraint: NSLayoutConstraint!
    
    private var descriptionToMoreRegularConstraint: NSLayoutConstraint!
    
    private var descriptionToMoreCompactConstraint: NSLayoutConstraint!
    
    private var displayAsCompact: Bool = false {
        didSet {
            if displayAsCompact == oldValue { return }
            
            if displayAsCompact {
                sourceLabel.font   = .systemFont(ofSize: 10.0, weight: UIFontWeightBold)
                titleLabel.font    = .preferredFont(forTextStyle: .headline)
                subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
                
                NSLayoutConstraint.deactivate(regularWidthConstraints)
                NSLayoutConstraint.activate(compactWidthConstraints)
            } else {
                sourceLabel.font   = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
                titleLabel.font    = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
                subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
                
                NSLayoutConstraint.deactivate(compactWidthConstraints)
                NSLayoutConstraint.activate(regularWidthConstraints)
            }
        }
    }
    
    
    
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
        
        sourceLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightBold)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.isHidden = true
        
        titleLabel.font  = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.isHidden = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .preferredFont(forTextStyle: .headline)
        descriptionLabel.isHidden = true
        
        additionalDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        additionalDetailsButton.titleLabel?.font = .systemFont(ofSize: 11, weight: UIFontWeightMedium)
        
        sourceLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.adjustsFontForContentSizeCategory = true
        additionalDetailsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        let compactMainContentGuide = UILayoutGuide()
        let mainLabelLayoutGuide   = UILayoutGuide()
        let detailLabelLayoutGuide = UILayoutGuide()
        
        let contentView = self.contentView
        contentView.addSubview(thumbnailView)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(additionalDetailsButton)
        
        contentView.addLayoutGuide(compactMainContentGuide)
        contentView.addLayoutGuide(mainLabelLayoutGuide)
        contentView.addLayoutGuide(detailLabelLayoutGuide)
        
        sourceToTitleConstraint   = NSLayoutConstraint(item: titleLabel,    attribute: .top, relatedBy: .equal, toItem: sourceLabel, attribute: .bottom) // 6.0 with content
        titleToSubtitleConstraint = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel,  attribute: .bottom) // 3.0 with content
        subtitleToDescriptionConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom) // 16.0 with content. Only active in regular mode.
        descriptionToMoreRegularConstraint = NSLayoutConstraint(item: additionalDetailsButton, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom) // 16.0 with content
        descriptionToMoreCompactConstraint = NSLayoutConstraint(item: additionalDetailsButton, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom) // 9.0 with content
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: sourceLabel, attribute: .leading,  relatedBy: .equal,           toItem: mainLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: sourceLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: mainLabelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: sourceLabel, attribute: .top, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .top),
            sourceToTitleConstraint,
            
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .equal,           toItem: mainLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: mainLabelLayoutGuide, attribute: .trailing),
            
            titleToSubtitleConstraint,
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .equal,           toItem: mainLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: mainLabelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: descriptionLabel, attribute: .top,      relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: descriptionLabel, attribute: .leading,  relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: descriptionLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: detailLabelLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .leading,  relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: detailLabelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .bottom,   relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .bottom,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .bottom),
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: thumbnailView, attribute: .leading,  relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: thumbnailView, attribute: .trailing, constant: 16.0),
        ])
        
        regularWidthConstraints = [
            NSLayoutConstraint(item: thumbnailView, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: thumbnailView, attribute: .height,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .height),
            NSLayoutConstraint(item: thumbnailView, attribute: .height,   relatedBy: .equal,           toItem: thumbnailView, attribute: .width),
            NSLayoutConstraint(item: thumbnailView, attribute: .width,    relatedBy: .equal,           toConstant: 202),
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .top, relatedBy: .equal, toItem: thumbnailView, attribute: .top, constant: 17.0),
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .leading),
            
            subtitleToDescriptionConstraint,
            descriptionToMoreRegularConstraint,
        ]
        NSLayoutConstraint.activate(regularWidthConstraints)
        
        compactWidthConstraints = [
            NSLayoutConstraint(item: thumbnailView, attribute: .width,  relatedBy: .equal, toConstant: 96.0),
            NSLayoutConstraint(item: thumbnailView, attribute: .height, relatedBy: .equal, toConstant: 96.0),
            
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .trailing, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: thumbnailView, attribute: .top, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .top),
            NSLayoutConstraint(item: thumbnailView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: compactMainContentGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .height, relatedBy: .lessThanOrEqual, toItem: compactMainContentGuide, attribute: .height),
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .centerY),
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .top, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .bottom, constant: 9.0),
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            
            descriptionToMoreCompactConstraint
        ]
        
        additionalDetailsButton.addTarget(self, action: #selector(additionalDescriptionsButtonDidSelect), for: .touchUpInside)
        
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
                updateForWidthChange()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.width !=~ oldValue.width {
                updateForWidthChange()
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            let layoutMargins = self.layoutMargins
            if layoutMargins.left !=~ oldValue.left || layoutMargins.right !=~ oldValue.right {
                updateForWidthChange()
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
                    descriptionToMoreRegularConstraint.constant = (hasTitle || hasSubtitle || hasDescription) && hasMoreDescription ? 16.0 : 0.0
                    descriptionToMoreCompactConstraint.constant = hasDescription && hasMoreDescription ? 8.0 : 0.0
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Sizing
    
    open class func displaysAsCompact(withContentWidth width: CGFloat) -> Bool {
        return width <=~ compactWidth
    }
    
    open class func minimumContentHeight(withTitle title: String?, subtitle: String?, description: String?, descriptionPlaceholder: String?, additionalDetails: String?, source: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        let displayAsCompact = displaysAsCompact(withContentWidth: width)
        let displayScale = traitCollection.currentDisplayScale
        
        var mainTextHeight: CGFloat
        
        let hasTitle:       Bool
        let hasDescription: Bool
        
        let maxMainTextSize = CGSize(width: (width - (displayAsCompact ? 112.0 : 218.0)).floored(toScale: displayScale), height: CGFloat.greatestFiniteMagnitude)
        
        let sourceFont: UIFont = .systemFont(ofSize: displayAsCompact ? 10.0 : 11.0, weight: UIFontWeightBold)
        
        let titleFont: UIFont = displayAsCompact ? .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection) : .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        let subtitleFont: UIFont = .preferredFont(forTextStyle: displayAsCompact ? .footnote : .subheadline, compatibleWith: traitCollection)
    
        if let title = title as NSString?, title.length > 0 {
            mainTextHeight = title.boundingRect(with: maxMainTextSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: titleFont], context: nil).height.ceiled(toScale: displayScale)
            hasTitle = true
        } else {
            mainTextHeight = 0.0
            hasTitle = false
        }
        
        if subtitle?.isEmpty ?? true == false {
            if hasTitle { mainTextHeight += 3.0 }
            mainTextHeight += subtitleFont.lineHeight.ceiled(toScale: displayScale)
        }
        
        if source?.isEmpty ?? true == false {
            mainTextHeight += sourceFont.lineHeight.ceiled(toScale: displayScale) + 11.0
        }
        
        var detailsHeight: CGFloat
        let detailsSize = CGSize(width: displayAsCompact ? width : maxMainTextSize.width, height: CGFloat.greatestFiniteMagnitude)
        if let descriptionText = (description ?? descriptionPlaceholder) as NSString?, descriptionText.length > 0 {
            let textStyle: UIFontTextStyle = description == nil ? .subheadline : .headline
            let descriptionFont: UIFont = .preferredFont(forTextStyle: textStyle, compatibleWith: traitCollection)
            
            hasDescription = true
            
            detailsHeight = descriptionText.boundingRect(with: detailsSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: descriptionFont], context: nil).height.ceiled(toScale: displayScale)
        } else {
            detailsHeight = 0.0
            hasDescription = false
        }
        
        if additionalDetails?.isEmpty ?? true == false {
            if hasDescription { detailsHeight += (displayAsCompact ? 8.0 : 16.0) }
            detailsHeight += UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium).lineHeight.ceiled(toScale: displayScale) + 13.0
        }
        
        var contentHeight: CGFloat
        if displayAsCompact {
            contentHeight = max(mainTextHeight, 96.0) // 96 is the height for the image view in compact mode.
            if detailsHeight > 0.0 {
                contentHeight += detailsHeight + 9.0
            }
        } else {
            if detailsHeight > 0.0 {
                mainTextHeight += detailsHeight + 16.0
            }
            contentHeight = max(mainTextHeight, 202.0) // 202 is the height for the image view in regular mode.
        }
        
        return contentHeight
    }
    
    
    // MARK: - Private methods
    
    private func updateForWidthChange() {
        let contentWidth = bounds.insetBy(layoutMargins).width
        displayAsCompact = EntityDetailCollectionViewCell.displaysAsCompact(withContentWidth: contentWidth)
        
        titleLabel.preferredMaxLayoutWidth = contentWidth - (displayAsCompact ? 112.0 : 218.0)
        descriptionLabel.preferredMaxLayoutWidth = contentWidth - (displayAsCompact ? 0.0 : 218.0)
    }
    
}
