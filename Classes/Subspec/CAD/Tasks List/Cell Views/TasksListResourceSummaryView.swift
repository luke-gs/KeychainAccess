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
        static let imageSize: CGFloat = 48
        static let verticalMargin: CGFloat = 16
    }
    
    /// Image view for the resource image
    open let imageView = UIImageView()
    
    /// Label for the resource title
    open let titleLabel = UILabel()
    
    /// Label for the resource location
    open let subtitleLabel = UILabel()
    
    /// Label for the resource status
    open let captionLabel = UILabel()
    
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
        
        captionLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: LayoutConstants.imageSize),
            imageView.widthAnchor.constraint(equalToConstant: LayoutConstants.imageSize),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            captionLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
}
