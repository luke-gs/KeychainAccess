//
//  SidebarHeaderView.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A header view for displaying general MPOL content in a sidebar.
open class SidebarHeaderView: UIView {
    /// Top constraint for subtitle label
    private var subtitleLabelTopConstraint: NSLayoutConstraint!
    
    /// Observer for title caption label text changes
    private var titleCaptionLabelTextObserver: NSKeyValueObservation?
    
    // MARK: Public properties
    
    /// The image view for the icon, initials or thumbnails.
    ///
    /// This is round masked. Adjust the icon view's background color and
    /// `contentMode` property to get the desired appearance.
    public let iconView: UIImageView = UIImageView(frame: .zero)
    
    /// The caption label below the icon.
    public let captionLabel: UILabel = UILabel(frame: .zero)
    
    /// The title label.
    public let titleLabel: UILabel = UILabel(frame: .zero)
    
    /// A label below the title but above the subtitle...
    public let titleCaptionLabel: UILabel = UILabel(frame: .zero)
    
    /// The subtitle label.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)
    
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
        preservesSuperviewLayoutMargins = true
        accessibilityTraits |= UIAccessibilityTraitHeader
        
        let secondaryColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.backgroundColor = #colorLiteral(red: 0.1642476916, green: 0.1795658767, blue: 0.2130921185, alpha: 1)
        iconView.clipsToBounds = true
        iconView.tintColor = secondaryColor
        
        let iconLayer = iconView.layer
        iconLayer.cornerRadius = 32.0
        iconLayer.shouldRasterize = true
        iconLayer.rasterizationScale = traitCollection.currentDisplayScale
        
        addSubview(iconView)
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.adjustsFontForContentSizeCategory = true
        captionLabel.font = .systemFont(ofSize: 10.0, weight: UIFont.Weight.bold)
        captionLabel.textColor = secondaryColor
        captionLabel.textAlignment = .center
        addSubview(captionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        titleCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleCaptionLabel.adjustsFontSizeToFitWidth = true
        titleCaptionLabel.adjustsFontForContentSizeCategory = true
        titleCaptionLabel.numberOfLines = 0
        titleCaptionLabel.textAlignment = .center
        titleCaptionLabel.font = .systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        titleCaptionLabel.textColor = .white
        addSubview(titleCaptionLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = secondaryColor
        addSubview(subtitleLabel)
        
        updateSubtitleFont()
        subtitleLabelTopConstraint = NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleCaptionLabel, attribute: .bottom, constant: 0)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: iconView, attribute: .width,  relatedBy: .equal, toConstant: 64.0).withPriority(UILayoutPriority.almostRequired),
            NSLayoutConstraint(item: iconView, attribute: .height, relatedBy: .equal, toConstant: 64.0).withPriority(UILayoutPriority.almostRequired),
            NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: iconView, attribute: .top,     relatedBy: .equal, toItem: self, attribute: .top, constant: 22.0),
            
            NSLayoutConstraint(item: captionLabel, attribute: .top,      relatedBy: .equal, toItem: iconView, attribute: .bottom, constant: 9.0),
            NSLayoutConstraint(item: captionLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: captionLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: captionLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),
            
            NSLayoutConstraint(item: titleLabel, attribute: .top,      relatedBy: .equal, toItem: captionLabel, attribute: .bottom, constant: 12.0),
            NSLayoutConstraint(item: titleLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: titleLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),

            NSLayoutConstraint(item: titleCaptionLabel, attribute: .top,      relatedBy: .equal, toItem: titleLabel, attribute: .bottom, constant: 8),
            NSLayoutConstraint(item: titleCaptionLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: titleCaptionLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: titleCaptionLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),

            subtitleLabelTopConstraint,
            NSLayoutConstraint(item: subtitleLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom,  relatedBy: .equal, toItem: self, attribute: .bottom, constant: -52.0).withPriority(UILayoutPriority.defaultHigh)
        ])
        
        // If the title caption label gets used, we need to update the subtitle label's offset so we don't have a huge gap when it's not used
        titleCaptionLabelTextObserver = titleCaptionLabel.observe(\.text) { [weak self] (label, value) in
            if let value = value.newValue??.ifNotEmpty() as? String? {
                self?.subtitleLabelTopConstraint.constant = 8
            } else {
                self?.subtitleLabelTopConstraint.constant = 0
            }
        }
    }
    
    deinit {
        titleCaptionLabelTextObserver?.invalidate()
        titleCaptionLabelTextObserver = nil
    }
    
    
    // MARK: - Updates
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        iconView.layer.rasterizationScale = traitCollection.currentDisplayScale
        
        if previousTraitCollection?.preferredContentSizeCategory ?? .large != traitCollection.preferredContentSizeCategory {
            updateSubtitleFont()
        }
    }
    
    // TODO: deprecate in iOS 11 when replacement API exists (UIFontMetrics)
    private func updateSubtitleFont() {
        let headerSubtitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        subtitleLabel.font = UIFont(descriptor: headerSubtitleDescriptor, size: headerSubtitleDescriptor.pointSize - 1.0)
    }
}
