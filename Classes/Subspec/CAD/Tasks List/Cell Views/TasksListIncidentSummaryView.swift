//
//  TasksListIncidentSummaryView.swift
//  MPOLKit
//
//  Created by Kyle May on 18/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListIncidentSummaryView: UIView {
    
    private struct LayoutConstants {
        static let verticalMargin: CGFloat = 16
    }
    
    // MARK: - Views
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subtitleLabel)
        
        priorityCaptionView.axis = .horizontal
        priorityCaptionView.spacing = 8
        priorityCaptionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(priorityCaptionView)
        
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
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            priorityCaptionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            priorityCaptionView.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            priorityCaptionView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                        constant: -LayoutConstants.verticalMargin),
            priorityCaptionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).withPriority(.almostRequired),
        ])
    }
    
}
