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
    private let leftColumn = ColumnView()
    
    /// Column in the middle
    private let middleColumn = ColumnView()
    
    /// Column on the right
    private let rightColumn = ColumnView()
    
    /// Content view for left column
    private let leftColumnContentView = UIView()
    
    /// Content view for middle column
    private let middleColumnContentView = UIView()
    
    /// Stack view for resources, content view for right column
    private let resourcesStack = UIStackView()
    
    /// View for showing updates indicator
    public let updatesIndicator = UIImageView()
    
    /// The text label for the cell
    public let titleLabel = UILabel()
    
    /// The subtitle label for the cell
    public let subtitleLabel = UILabel()
    
    /// Stack view for the priority and caption labels
    public let priorityCaptionView = UIStackView()
    
    /// Priority rounded rect label
    public let priorityLabel = RoundedRectLabel()
    
    /// Label next to priority icon
    public let captionLabel = UILabel()
    
    /// The label for the middle details section of the cell where space is available
    public let detailLabel = UILabel()
    
    public var leftColumnWidth: NSLayoutConstraint!
    public var middleColumnWidth: NSLayoutConstraint!
    public var rightColumnWidth: NSLayoutConstraint!

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
        
        leftColumn.columnInfo = ColumnInfo(minimumWidth: 200, maximumWidth: 280)
        leftColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftColumn)
        
        leftColumnContentView.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.addSubview(leftColumnContentView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftColumnContentView.addSubview(titleLabel)
        
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftColumnContentView.addSubview(subtitleLabel)
        
        priorityCaptionView.axis = .horizontal
        priorityCaptionView.spacing = 8
        priorityCaptionView.translatesAutoresizingMaskIntoConstraints = false
        leftColumnContentView.addSubview(priorityCaptionView)
        
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
        
        // Middle column
        
        middleColumn.columnInfo = ColumnInfo(minimumWidth: 300, maximumWidth: 1000)
        middleColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(middleColumn)
        
        middleColumnContentView.translatesAutoresizingMaskIntoConstraints = false
        middleColumn.addSubview(middleColumnContentView)
        
        detailLabel.textColor = .secondaryGray
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailLabel.numberOfLines = 3
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        middleColumnContentView.addSubview(detailLabel)
        
        // Right column
        
        rightColumn.columnInfo = ColumnInfo(minimumWidth: 192, maximumWidth: 192)
        rightColumn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightColumn)
        
        resourcesStack.axis = .vertical
        resourcesStack.alignment = .top
        resourcesStack.spacing = 10
        resourcesStack.distribution = .fill
        resourcesStack.translatesAutoresizingMaskIntoConstraints = false
        rightColumn.addSubview(resourcesStack)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        priorityLabel.setContentHuggingPriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        leftColumnWidth = leftColumn.widthAnchor.constraint(equalToConstant: 0)
        middleColumnWidth = middleColumn.widthAnchor.constraint(equalToConstant: 0)
        rightColumnWidth = rightColumn.widthAnchor.constraint(equalToConstant: 0)
        
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

            leftColumnContentView.topAnchor.constraint(equalTo: leftColumn.topAnchor),
            leftColumnContentView.bottomAnchor.constraint(equalTo: leftColumn.bottomAnchor),
            leftColumnContentView.leadingAnchor.constraint(equalTo: leftColumn.leadingAnchor),
            leftColumnContentView.trailingAnchor.constraint(equalTo: leftColumn.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: leftColumnContentView.topAnchor, constant: LayoutConstants.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leftColumnContentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: leftColumnContentView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: leftColumnContentView.trailingAnchor),

            priorityCaptionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            priorityCaptionView.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            priorityCaptionView.bottomAnchor.constraint(equalTo: leftColumnContentView.bottomAnchor,
                                                        constant: -LayoutConstants.verticalMargin),
            priorityCaptionView.trailingAnchor.constraint(equalTo: leftColumnContentView.trailingAnchor),
            
            // Middle column
            
            middleColumn.topAnchor.constraint(equalTo: contentView.topAnchor),
            middleColumn.leadingAnchor.constraint(equalTo: leftColumn.trailingAnchor),
            middleColumn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            middleColumnWidth,
            
            middleColumnContentView.topAnchor.constraint(equalTo: middleColumn.topAnchor),
            middleColumnContentView.bottomAnchor.constraint(equalTo: middleColumn.bottomAnchor),
            middleColumnContentView.leadingAnchor.constraint(equalTo: middleColumn.leadingAnchor,
                                                             constant: LayoutConstants.columnSpacing).withPriority(.defaultHigh),
            middleColumnContentView.trailingAnchor.constraint(equalTo: middleColumn.trailingAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: middleColumnContentView.topAnchor,
                                             constant: LayoutConstants.verticalMargin),
            detailLabel.leadingAnchor.constraint(equalTo: middleColumnContentView.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: middleColumnContentView.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: middleColumnContentView.bottomAnchor,
                                                constant: -LayoutConstants.verticalMargin),
            
            // Right column
            
            resourcesStack.topAnchor.constraint(equalTo: rightColumn.topAnchor),
            resourcesStack.bottomAnchor.constraint(equalTo: rightColumn.bottomAnchor),
            resourcesStack.leadingAnchor.constraint(equalTo: rightColumn.leadingAnchor,
                                                    constant: LayoutConstants.columnSpacing).withPriority(.defaultHigh),
            resourcesStack.trailingAnchor.constraint(equalTo: rightColumn.trailingAnchor),
            
            rightColumn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.verticalMargin),
            rightColumn.leadingAnchor.constraint(equalTo: middleColumn.trailingAnchor),
            rightColumn.trailingAnchor.constraint(equalTo: accessoryView?.leadingAnchor ?? contentView.trailingAnchor)
                .withPriority(.almostRequired),
            rightColumn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightColumnWidth,
        ])
    }
    
    public override var bounds: CGRect {
        didSet {
            let views = [leftColumn, middleColumn, rightColumn]
            
            let calculatedWidths = ColumnInfo.calculateWidths(for: views.map { $0.columnInfo }, in: bounds.width - 56)
            
            for (width, view) in zip(calculatedWidths, views) {
                view.columnInfo.actualWidth = width
                view.isHidden = width == 0
            }
            
            leftColumnWidth.priority = .required
            middleColumnWidth.priority = .required
            rightColumnWidth.priority = .required
            
            leftColumnWidth.constant = leftColumn.columnInfo.actualWidth
            middleColumnWidth.constant = middleColumn.columnInfo.actualWidth
            rightColumnWidth.constant = rightColumn.columnInfo.actualWidth
        }
    }
    
    public func configurePriority(text: String?, textColor: UIColor?, fillColor: UIColor?, borderColor: UIColor?) {
        priorityLabel.text = text
        priorityLabel.textColor = textColor
        priorityLabel.backgroundColor = fillColor
        priorityLabel.borderColor = borderColor
        
        priorityLabel.isHidden = text == nil
    }
    
    public func setStatusRows(_ viewModels: [TasksListItemResourceViewModel]?) {
        resourcesStack.removeArrangedSubviewsFromViewHeirachy()
        
        guard let viewModels = viewModels else { return }
        
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
            resourcesStack.addArrangedSubview(statusRow)
        }
        
        // Add spacer view if less than 4 views
        if resourcesStack.arrangedSubviews.count < 4 {
            resourcesStack.addArrangedSubview(UIView())
        }
    }
}
