//
//  TasksListItemCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemCollectionViewCell: ColumnCollectionViewCell {
    
    private struct LayoutConstants {
        static let updatesIndicatorSize: CGFloat = 10
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 8
        static let columnSpacing: CGFloat = 24
        static let accessorySize: CGFloat = 16
    }
    
    // MARK: - Views
    
    /// Content view for left column
    private let leftColumnContentView = UIView()
    
    /// Content view for middle column
    private let middleColumnContentView = UIView()
    
    /// Content view for right column
    private let rightColumnContentView = UIView()
    
    /// Stack view for resources
    private let resourcesStackView = UIStackView()
    
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

    public override func commonInit() {
        super.commonInit()
        dataSource = self
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
        
        detailLabel.textColor = .secondaryGray
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailLabel.numberOfLines = 3
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        middleColumnContentView.addSubview(detailLabel)
        
        // Right column
        
        resourcesStackView.axis = .vertical
        resourcesStackView.alignment = .top
        resourcesStackView.spacing = 10
        resourcesStackView.distribution = .fill
        resourcesStackView.translatesAutoresizingMaskIntoConstraints = false
        rightColumnContentView.addSubview(resourcesStackView)
        
        construct()
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        priorityLabel.setContentHuggingPriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            updatesIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            updatesIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalMargin),
            updatesIndicator.heightAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            updatesIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            
            // Left column
            
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

            detailLabel.topAnchor.constraint(equalTo: middleColumnContentView.topAnchor,
                                             constant: LayoutConstants.verticalMargin),
            detailLabel.leadingAnchor.constraint(equalTo: middleColumnContentView.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: middleColumnContentView.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: middleColumnContentView.bottomAnchor,
                                                constant: -LayoutConstants.verticalMargin),
            
            // Right column
            
            resourcesStackView.topAnchor.constraint(equalTo: rightColumnContentView.topAnchor, constant: LayoutConstants.verticalMargin),
            resourcesStackView.leadingAnchor.constraint(equalTo: rightColumnContentView.leadingAnchor),
            resourcesStackView.trailingAnchor.constraint(equalTo: rightColumnContentView.trailingAnchor),
            resourcesStackView.bottomAnchor.constraint(equalTo: rightColumnContentView.bottomAnchor),
        ])
    }
    
    public func configurePriority(text: String?, textColor: UIColor?, fillColor: UIColor?, borderColor: UIColor?) {
        priorityLabel.text = text
        priorityLabel.textColor = textColor
        priorityLabel.backgroundColor = fillColor
        priorityLabel.borderColor = borderColor
        
        priorityLabel.isHidden = text == nil
    }
    
    public func setStatusRows(_ viewModels: [TasksListItemResourceViewModel]?) {
        resourcesStackView.removeArrangedSubviewsFromViewHeirachy()
        
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
            resourcesStackView.addArrangedSubview(statusRow)
        }
        
        // Add spacer view if less than 4 views
        if resourcesStackView.arrangedSubviews.count < 4 {
            resourcesStackView.addArrangedSubview(UIView())
        }
    }
}

extension TasksListItemCollectionViewCell: ColumnCollectionViewCellDataSource {
    public func numberOfColumns() -> Int {
        return 3
    }
    
    public func columnInfo(at index: Int) -> ColumnInfo {
        switch index {
        case 0:
            return ColumnInfo(minimumWidth: 200, maximumWidth: 280)
        case 1:
            return ColumnInfo(minimumWidth: 300, maximumWidth: 1000)
        case 2:
            return ColumnInfo(minimumWidth: 192, maximumWidth: 192)
        default: return .zero
        }
    }
    
    public func viewForColumn(at index: Int) -> UIView {
        switch index {
        case 0:
            return leftColumnContentView
        case 1:
            return middleColumnContentView
        case 2:
            return rightColumnContentView
        default: return UIView()
        }
    }
    
    public func columnSpacing() -> CGFloat {
        return LayoutConstants.columnSpacing
    }
    
    public func widthOffset() -> CGFloat {
        return LayoutConstants.accessorySize
    }
    
}
