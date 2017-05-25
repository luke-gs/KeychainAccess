//
//  EntityDetailsHeaderView.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A header view for displaying an entity summary in a sidebar.
open class EntityDetailsSidebarHeaderView: UIView {
    
    // MARK: Public properties
    
    /// The image view for a thumbnail or initials. This is round masked.
    public let thumbnailView: UIImageView = UIImageView(frame: .zero)
    
    
    /// The type label for displaying the entity's localized display type.
    public let typeLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The summary label. This is for displaying a one line summary description
    /// of the entity.
    public let summaryLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The last updated label. This should be used to show details of when the
    /// entity was last updated in the database.
    public let lastUpdatedLabel: UILabel = UILabel(frame: .zero)
    
    
    // MARK: - Private properties
    
    private let sectionSeparator: UIImageView = UIImageView(image: UIImage(named: "SectionSeparator", in: .mpolKit, compatibleWith: nil))
    
    
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
        
        let secondaryColor = #colorLiteral(red: 0.5561795831, green: 0.5791077614, blue: 0.6335693598, alpha: 1)
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.backgroundColor = #colorLiteral(red: 0.1642476916, green: 0.1795658767, blue: 0.2130921185, alpha: 1)
        thumbnailView.clipsToBounds = true
        thumbnailView.tintColor = secondaryColor
        
        let thumbnailLayer = thumbnailView.layer
        thumbnailLayer.cornerRadius = 32.0
        thumbnailLayer.shouldRasterize = true
        thumbnailLayer.rasterizationScale = traitCollection.currentDisplayScale
        
        addSubview(thumbnailView)
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.font = .systemFont(ofSize: 10.0, weight: UIFontWeightBold)
        typeLabel.textColor = secondaryColor
        typeLabel.textAlignment = .center
        addSubview(typeLabel)
        
        sectionSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionSeparator)
        
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.adjustsFontSizeToFitWidth = true
        summaryLabel.numberOfLines = 0
        summaryLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        summaryLabel.textColor = .white
        summaryLabel.textAlignment = .center
        addSubview(summaryLabel)
        
        lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = false
        lastUpdatedLabel.adjustsFontSizeToFitWidth = true
        lastUpdatedLabel.numberOfLines = 0
        lastUpdatedLabel.textAlignment = .center
        lastUpdatedLabel.textColor = secondaryColor
        addSubview(lastUpdatedLabel)
        
        updateFonts()
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: thumbnailView, attribute: .width,  relatedBy: .equal, toConstant: 64.0),
            NSLayoutConstraint(item: thumbnailView, attribute: .height, relatedBy: .equal, toConstant: 64.0),
            NSLayoutConstraint(item: thumbnailView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: thumbnailView, attribute: .top,     relatedBy: .equal, toItem: self, attribute: .top, constant: 22.0),
            
            NSLayoutConstraint(item: typeLabel, attribute: .top,      relatedBy: .equal, toItem: thumbnailView, attribute: .bottom, constant: 9.0),
            NSLayoutConstraint(item: typeLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: typeLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: typeLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),
            
            NSLayoutConstraint(item: summaryLabel, attribute: .top,      relatedBy: .equal, toItem: typeLabel, attribute: .bottom, constant: 12.0),
            NSLayoutConstraint(item: summaryLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: summaryLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: summaryLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),
            
            NSLayoutConstraint(item: lastUpdatedLabel, attribute: .top,      relatedBy: .equal, toItem: summaryLabel, attribute: .bottom, constant: 8.0),
            NSLayoutConstraint(item: lastUpdatedLabel, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: lastUpdatedLabel, attribute: .leading,  relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leadingMargin),
            NSLayoutConstraint(item: lastUpdatedLabel, attribute: .trailing, relatedBy: .lessThanOrEqual,    toItem: self, attribute: .trailingMargin),
            
            NSLayoutConstraint(item: sectionSeparator, attribute: .top,     relatedBy: .equal, toItem: lastUpdatedLabel, attribute: .bottom, constant: 23.0),
            NSLayoutConstraint(item: sectionSeparator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: sectionSeparator, attribute: .bottom,  relatedBy: .equal, toItem: self, attribute: .bottom, constant: -11.0, priority: UILayoutPriorityDefaultHigh)
        ])
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFonts), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    
    // MARK: - Updates
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        thumbnailView.layer.rasterizationScale = traitCollection.currentDisplayScale
        
        if #available(iOS 10.0, *), previousTraitCollection?.preferredContentSizeCategory ?? .large != traitCollection.preferredContentSizeCategory {
            updateFonts()
        }
    }
    
    @objc private func updateFonts() {
        let headerSubtitleDescriptor: UIFontDescriptor
        if #available(iOS 10, *) {
            headerSubtitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            headerSubtitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        }
        lastUpdatedLabel.font = UIFont(descriptor: headerSubtitleDescriptor, size: headerSubtitleDescriptor.pointSize - 1.0)
    }
}
