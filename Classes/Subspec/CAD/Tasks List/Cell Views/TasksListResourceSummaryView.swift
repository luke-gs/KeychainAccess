//
//  TasksListResourceSummaryView.swift
//  MPOLKit
//
//  Created by Kyle May on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListResourceSummaryView: UIView {

    private struct LayoutConstants {
        static let resourceImageSize: CGFloat = 48
        static let statusImageSize: CGFloat = 32
        static let margin: CGFloat = 16
    }
    
    /// Image view for the resource image
    open let resourceImageView = UIImageView()
    
    /// Label for the resource title
    open let titleLabel = UILabel()
    
    /// Label for the resource location
    open let subtitleLabel = UILabel()

    /// Stack view for the priority and caption labels
    open let priorityCaptionView = UIStackView()
    
    /// Priority rounded rect label
    open let priorityLabel = RoundedRectLabel()

    /// Label for the resource status
    open let captionLabel = UILabel()
    
    /// Image view for the status image
    open let statusImageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        resourceImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resourceImageView)
        
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusImageView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
        
        priorityCaptionView.axis = .horizontal
        priorityCaptionView.spacing = 8
        priorityCaptionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(priorityCaptionView)
        
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
        priorityLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        captionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            resourceImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            resourceImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            resourceImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.resourceImageSize),
            resourceImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.resourceImageSize),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.margin),
            titleLabel.leadingAnchor.constraint(equalTo: resourceImageView.trailingAnchor, constant: LayoutConstants.margin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusImageView.leadingAnchor, constant: -LayoutConstants.margin),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusImageView.leadingAnchor, constant: -LayoutConstants.margin),
            
            priorityCaptionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            priorityCaptionView.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            priorityCaptionView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                        constant: -LayoutConstants.margin),
            priorityCaptionView.trailingAnchor.constraint(lessThanOrEqualTo: statusImageView.leadingAnchor, constant: -LayoutConstants.margin)
                .withPriority(.almostRequired),
            
            statusImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.margin),
            statusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            statusImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.statusImageSize),
            statusImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.statusImageSize),
        ])
    }
    
}
