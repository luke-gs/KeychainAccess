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
        
        if #available(iOS 10, *) {
            sourceLabel.adjustsFontForContentSizeCategory = true
            titleLabel.adjustsFontForContentSizeCategory = true
            subtitleLabel.adjustsFontForContentSizeCategory = true
            descriptionLabel.adjustsFontForContentSizeCategory = true
            additionalDetailsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
        
        borderedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        let compactMainContentGuide = UILayoutGuide()
        let mainLabelLayoutGuide   = UILayoutGuide()
        let detailLabelLayoutGuide = UILayoutGuide()
        
        let contentView = self.contentView
        contentView.addSubview(borderedImageView)
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
        subtitleToDescriptionConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom) // 16.0 with content. Only active in regular mode
        descriptionToMoreConstraint = NSLayoutConstraint(item: additionalDetailsButton, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom) // 16.0 with content
        
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
            
            descriptionToMoreConstraint,
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .leading,  relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: detailLabelLayoutGuide, attribute: .trailing),
            NSLayoutConstraint(item: additionalDetailsButton, attribute: .bottom,   relatedBy: .equal,           toItem: detailLabelLayoutGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .bottom,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .bottom),
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: borderedImageView, attribute: .leading,  relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: borderedImageView, attribute: .trailing, constant: 16.0),
        ])
        
        regularWidthConstraints = [
            NSLayoutConstraint(item: borderedImageView, attribute: .top,      relatedBy: .equal,           toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,   relatedBy: .lessThanOrEqual, toItem: contentModeLayoutGuide, attribute: .height),
            NSLayoutConstraint(item: borderedImageView, attribute: .height,   relatedBy: .equal,           toItem: borderedImageView, attribute: .width),
            NSLayoutConstraint(item: borderedImageView, attribute: .width,    relatedBy: .equal,           toConstant: 202),
            
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .top, relatedBy: .equal, toItem: borderedImageView, attribute: .top, constant: 17.0),
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .leading),
            
            subtitleToDescriptionConstraint
        ]
        NSLayoutConstraint.activate(regularWidthConstraints)
        
        compactWidthConstraints = [
            NSLayoutConstraint(item: borderedImageView, attribute: .width,  relatedBy: .equal, toConstant: 96.0),
            NSLayoutConstraint(item: borderedImageView, attribute: .height, relatedBy: .equal, toConstant: 96.0),
            
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .top, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .top),
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
            NSLayoutConstraint(item: compactMainContentGuide, attribute: .trailing, relatedBy: .equal, toItem: mainLabelLayoutGuide, attribute: .trailing),
            
            NSLayoutConstraint(item: borderedImageView, attribute: .top, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .top),
            NSLayoutConstraint(item: borderedImageView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: compactMainContentGuide, attribute: .bottom),
            
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .height, relatedBy: .lessThanOrEqual, toItem: compactMainContentGuide, attribute: .height),
            NSLayoutConstraint(item: mainLabelLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .centerY),
            
            
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .top, relatedBy: .equal, toItem: compactMainContentGuide, attribute: .bottom, constant: 12.0),
            NSLayoutConstraint(item: detailLabelLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .leading),
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
                    descriptionToMoreConstraint.constant     = (hasTitle || hasSubtitle || hasDescription) && hasMoreDescription ? 16.0 : 0.0
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
        super.contentSizeCategoryDidChange(newCategory)
        
        if #available(iOS 10, *) { return }        
        
        sourceLabel.legacy_adjustFontForContentSizeCategoryChange()
        titleLabel.legacy_adjustFontForContentSizeCategoryChange()
        subtitleLabel.legacy_adjustFontForContentSizeCategoryChange()
        descriptionLabel.legacy_adjustFontForContentSizeCategoryChange()
        additionalDetailsButton.titleLabel?.legacy_adjustFontForContentSizeCategoryChange()
    }
    
    
//    internal override func applyStandardFonts() {
//        super.applyStandardFonts()
//        
//        if #available(iOS 10, *) {
//            subtitleLabel.font    = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
//            descriptionLabel.font = .preferredFont(forTextStyle: .headline,    compatibleWith: traitCollection)
//        } else {
//
//            descriptionLabel.font =
//        }
//    }
    
    
    // MARK: - Siing
    
    public class func displaysAsCompact(withContentWidth width: CGFloat) -> Bool {
        return width <=~ compactWidth
    }
    
    public class func minimumContentHeight(withTitle title: String?, subtitle: String?, description: String?, additionalDetails: String?, source: String?, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        
        let displayAsCompact = displaysAsCompact(withContentWidth: width)
        let displayScale = traitCollection.currentDisplayScale
        
        var textHeight: CGFloat
        
        let hasTitle:       Bool
        let hasSubtitle:    Bool
        let hasDescription: Bool
        
        let maxTextSize = CGSize(width: (displayAsCompact ? width : width - 217.0).floored(toScale: displayScale), height: CGFloat.greatestFiniteMagnitude)
        
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
        
        return displayAsCompact ? textHeight : max(textHeight, 202.0) // 202 is the height for the image view in non-compact mode.
    }
    
    
    // MARK: - Private methods
    
    private func updateForWidthChange() {
        let contentWidth = bounds.insetBy(layoutMargins).width
        displayAsCompact = EntityDetailCollectionViewCell.displaysAsCompact(withContentWidth: contentWidth)
        
        titleLabel.preferredMaxLayoutWidth = contentWidth - (displayAsCompact ? 112.0 : 218.0)
        descriptionLabel.preferredMaxLayoutWidth = contentWidth - (displayAsCompact ? 0.0 : 218.0)
    }
    
}
