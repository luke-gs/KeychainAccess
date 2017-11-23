//
//  TasksListItemCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemCollectionViewCell: CollectionViewFormCell {
    
    private struct LayoutConstants {
        static let updatesIndicatorSize: CGFloat = 10
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 8
        static let textMargin: CGFloat = 4
        static let columnSpacing: CGFloat = 24
        static let priorityHeight: CGFloat = 16
        static let priorityWidth: CGFloat = 24
    }
    
    // MARK: - Views

    /// Column on the left
    private let leftColumn = UIView()
    
    /// Column in the middle
    private let middleColumn = UIView()
    
    /// Column on the right
    private let rightColumn = UIStackView()
    
    /// View for showing updates indicator
    public let updatesIndicator = UIImageView()
    
    /// The text label for the cell
    public let titleLabel = UILabel()
    
    /// The subtitle label for the cell
    public let subtitleLabel = UILabel()
    
    /// Rounded rect showing the priority level colour
    public let priorityBackground = UIView()
    
    /// Label inside priority rect showing the priority level text
    public let priorityLabel = UILabel()
    
    /// Label next to priority icon
    public let captionLabel = UILabel()
    
    /// The label for the middle details section of the cell where space is available
    public let detailLabel = UILabel()
    
    public var leftColumnWidth: NSLayoutConstraint!
    public var leftColumnTrailing: NSLayoutConstraint!
    public var middleColumnTrailing: NSLayoutConstraint!

    public override func commonInit() {
        super.commonInit()
        
        setupViews()
        setupConstraints()
    }
    
    /// Creates and styles views
    private func setupViews() {
        // Hide updates indicator by default
        updatesIndicator.isHidden = true
        updatesIndicator.image = UIImage.statusDot(withColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1))
        updatesIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(updatesIndicator)
        
        // Left column
        leftColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftColumn)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.addSubview(subtitleLabel)
        
        priorityBackground.layer.cornerRadius = 2
        priorityBackground.layer.borderWidth = 1
        priorityBackground.backgroundColor = .green
        priorityBackground.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.addSubview(priorityBackground)
        
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityBackground.addSubview(priorityLabel)
        
        captionLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.addSubview(captionLabel)
        
        // Middle column
        middleColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(middleColumn)
        
        detailLabel.textColor = .secondaryGray
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailLabel.numberOfLines = 3
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        middleColumn.addSubview(detailLabel)
        
        // Right column
        rightColumn.axis = .vertical
        rightColumn.alignment = .top
        rightColumn.spacing = 10
        rightColumn.distribution = .fill
        rightColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightColumn)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        priorityBackground.setContentHuggingPriority(.required, for: .horizontal)
        priorityLabel.setContentHuggingPriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftColumn.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        middleColumn.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightColumn.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        leftColumnWidth = leftColumn.widthAnchor.constraint(equalToConstant: 280).withPriority(.defaultHigh)
        leftColumnTrailing = leftColumn.trailingAnchor.constraint(equalTo: accessoryView?.leadingAnchor ?? contentView.layoutMarginsGuide.trailingAnchor, constant: -LayoutConstants.verticalMargin)
        middleColumnTrailing = middleColumn.trailingAnchor.constraint(equalTo: accessoryView?.leadingAnchor ?? contentView.layoutMarginsGuide.trailingAnchor, constant: -LayoutConstants.verticalMargin)

        NSLayoutConstraint.activate([
            updatesIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            updatesIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalMargin),
            updatesIndicator.heightAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            updatesIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            
            // Left column
            
            leftColumn.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftColumn.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            leftColumn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftColumnWidth,
            leftColumnTrailing,
            
            titleLabel.topAnchor.constraint(equalTo: leftColumn.topAnchor, constant: LayoutConstants.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leftColumn.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: leftColumn.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: leftColumn.trailingAnchor),
            
            priorityBackground.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            priorityBackground.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            priorityBackground.bottomAnchor.constraint(equalTo: leftColumn.bottomAnchor, constant: -LayoutConstants.verticalMargin),
            priorityBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.priorityHeight),
            priorityBackground.widthAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.priorityWidth),
            
            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: LayoutConstants.textMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: LayoutConstants.textMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -LayoutConstants.textMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -LayoutConstants.textMargin),
            
            captionLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor),
            captionLabel.leadingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: LayoutConstants.horizontalMargin),
            captionLabel.trailingAnchor.constraint(equalTo: leftColumn.trailingAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor),
            
            // Middle column
            
            middleColumn.topAnchor.constraint(equalTo: contentView.topAnchor),
            middleColumn.leadingAnchor.constraint(equalTo: leftColumn.trailingAnchor, constant: LayoutConstants.columnSpacing),
            middleColumn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: middleColumn.topAnchor, constant: LayoutConstants.verticalMargin),
            detailLabel.leadingAnchor.constraint(equalTo: middleColumn.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: middleColumn.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: middleColumn.bottomAnchor, constant: -LayoutConstants.verticalMargin),
            
            // Right column
            
            rightColumn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.verticalMargin),
            rightColumn.leadingAnchor.constraint(equalTo: middleColumn.trailingAnchor, constant: LayoutConstants.columnSpacing),
            rightColumn.trailingAnchor.constraint(equalTo: accessoryView?.leadingAnchor ?? contentView.layoutMarginsGuide.trailingAnchor, constant: -LayoutConstants.verticalMargin).withPriority(.almostRequired),
            rightColumn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    public override var bounds: CGRect {
        didSet {
            if bounds.width > 800 {
                leftColumnTrailing.isActive = false
                leftColumnWidth.isActive = true
                middleColumnTrailing.isActive = false
                rightColumn.isHidden = false
            } else if bounds.width > 700 {
                leftColumnTrailing.isActive = false
                leftColumnWidth.isActive = true
                middleColumnTrailing.isActive = true
                rightColumn.isHidden = true
            } else {
                middleColumnTrailing.isActive = false
                leftColumnWidth.isActive = false
                leftColumnTrailing.isActive = true
                rightColumn.isHidden = true
            }
        }
    }
    
    public func configurePriority(color priorityColor: UIColor, priorityText: String, priorityFilled: Bool) {
        priorityLabel.text = priorityText
        
        // Set background color or border color depending on whether filled
        if priorityFilled {
            priorityBackground.backgroundColor = priorityColor
            priorityBackground.layer.borderColor = UIColor.clear.cgColor
            priorityLabel.textColor = .black
        } else {
            priorityBackground.backgroundColor = .clear
            priorityBackground.layer.borderColor = priorityColor.cgColor
            priorityLabel.textColor = priorityColor
        }
    }
    
    public func setStatusRows(_ viewModels: [TasksListItemResourceViewModel]?) {
        guard let viewModels = viewModels else { return }
        
        rightColumn.removeArrangedSubviewsFromViewHeirachy()
        
        // Add first 3 view models
        for viewModel in viewModels[0..<min(3, viewModels.count)] {
            let statusRow = TasksListCellStatusRow()
            statusRow.imageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
            statusRow.imageView.tintColor = viewModel.tintColor ?? .secondaryGray
            statusRow.titleLabel.text = viewModel.resourceTitle
            statusRow.titleLabel.textColor = viewModel.tintColor ?? .secondaryGray
            statusRow.subtitleLabel.text = viewModel.statusText
            statusRow.subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: viewModel.useBoldStatusText ? .semibold : .regular)
            statusRow.subtitleLabel.textColor = viewModel.tintColor ?? .secondaryGray
            rightColumn.addArrangedSubview(statusRow)
        }
        
        // Add spacer view if less than 4 views
        if rightColumn.arrangedSubviews.count < 4 {
            rightColumn.addArrangedSubview(UIView())
        }
    }
}
