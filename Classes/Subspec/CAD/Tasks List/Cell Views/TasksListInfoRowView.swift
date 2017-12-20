//
//  TasksListInfoRowView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Row for the status column in landscape on tasks list
open class TasksListInfoRowView: UIView {

    private struct LayoutConstants {
        static let imageSize = CGSize(width: 16, height: 16)
        static let imageSpacing: CGFloat = 12
        static let textSpacing: CGFloat = 8
    }
    
    // MARK: - Views
    
    /// The image view showing the resource
    open let imageView = UIImageView()
    
    /// The title label for callsign
    open let titleLabel = UILabel()
    
    /// The subtitle label for status
    open let subtitleLabel = UILabel()
    
    // MARK: - Setup
    
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
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: LayoutConstants.imageSize.width).withPriority(.almostRequired),
            imageView.heightAnchor.constraint(equalToConstant: LayoutConstants.imageSize.height).withPriority(.almostRequired),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: LayoutConstants.imageSpacing).withPriority(.almostRequired),
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 35),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: LayoutConstants.textSpacing).withPriority(.almostRequired),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    open func decorate(with viewModel: TasksListInformationRowViewModel) {
        imageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = viewModel.tintColor ?? .secondaryGray
        titleLabel.text = viewModel.title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: viewModel.useBoldTitleText ? .semibold : .regular)
        titleLabel.textColor = viewModel.tintColor ?? .secondaryGray
        subtitleLabel.text = viewModel.detail
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: viewModel.useBoldDetailText ? .semibold : .regular)
        subtitleLabel.textColor = viewModel.tintColor ?? .secondaryGray
    }
    
}
