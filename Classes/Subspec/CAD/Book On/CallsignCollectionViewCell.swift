//
//  CallsignCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignCollectionViewCell: CollectionViewFormCell {
    
    /// Image view for the resource
    open let imageView = UIImageView()
    
    /// The title label
    open let titleLabel = UILabel()
    
    /// The subtitle label
    open let subtitleLabel = UILabel()
    
    /// Stack view for the priority and caption labels
    open let priorityCaptionView = UIStackView()
    
    /// Priority rounded rect label
    open let priorityLabel = RoundedRectLabel()
    
    /// Label next to priority icon
    open let captionLabel = UILabel()
    
    // MARK: - Setup
    
    open override func commonInit() {
        super.commonInit()
        setupViews()
        setupConstraints()
    }

    /// Creates and styles views
    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        priorityCaptionView.axis = .horizontal
        priorityCaptionView.spacing = 8
        priorityCaptionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priorityCaptionView)
        
        var edgeInsets = RoundedRectLabel.defaultLayoutMargins
        edgeInsets.left = 6
        edgeInsets.right = 6
        
        priorityLabel.layoutMargins = edgeInsets
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityCaptionView.addArrangedSubview(priorityLabel)
        
        captionLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityCaptionView.addArrangedSubview(captionLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        priorityLabel.setContentHuggingPriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            priorityCaptionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            priorityCaptionView.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            priorityCaptionView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                        constant: -16),
            priorityCaptionView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor)
                .withPriority(.almostRequired),
        ])
    }
    
    open func decorate(with viewModel: NotBookedOnCallsignItemViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        captionLabel.text = viewModel.caption
        imageView.image = viewModel.image
        
        priorityLabel.text = viewModel.badgeText
        priorityLabel.textColor = viewModel.badgeTextColor
        priorityLabel.backgroundColor = viewModel.badgeFillColor
        priorityLabel.borderColor = viewModel.badgeBorderColor
        priorityLabel.isHidden = viewModel.badgeText == nil
    }
    
    open func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .primaryText)
        subtitleLabel.textColor = theme.color(forKey: .secondaryText)
        captionLabel.textColor = theme.color(forKey: .secondaryText)
    }
}
