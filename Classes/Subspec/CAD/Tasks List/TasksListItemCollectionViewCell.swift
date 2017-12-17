//
//  TasksListItemCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemCollectionViewCell: CollectionViewFormCell {
    
    enum Column: Int {
        case overview = 0
        case detail = 1
        case resources = 2
        
        var columnInfo: ColumnInfo {
            switch self {
            case .overview:
                return ColumnInfo(minimumWidth: 200, maximumWidth: 280)
            case .detail:
                return ColumnInfo(minimumWidth: 300, maximumWidth: 1000)
            case .resources:
                return ColumnInfo(minimumWidth: 192, maximumWidth: 192)
            }
        }
    }
    
    private struct LayoutConstants {
        static let updatesIndicatorSize: CGFloat = 10
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 8
        static let columnSpacing: CGFloat = 24
        static let accessorySize: CGFloat = 16
    }
    
    // MARK: - Views
    
    private let columnContainer = ColumnContainerView()
    
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
    
    // MARK: - Properties
    
    /// Constraints for the content views
    private var contentConstraints: [NSLayoutConstraint] = []
    
    /// Columns to show
    private var columns: Set<Column> = [.overview]
    
    public override func commonInit() {
        super.commonInit()
        columnContainer.dataSource = self
        setupViews()
    }
    
    /// Creates and styles views
    private func setupViews() {
        leftColumnContentView.translatesAutoresizingMaskIntoConstraints = false
        middleColumnContentView.translatesAutoresizingMaskIntoConstraints = false
        rightColumnContentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(columnContainer)
        columnContainer.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        NSLayoutConstraint.activate([
            columnContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            columnContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -LayoutConstants.accessorySize),
            columnContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            columnContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// Activates content view constraints
    private func addContentViewConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        priorityLabel.setContentHuggingPriority(.required, for: .horizontal)
        captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.deactivate(contentConstraints)
        contentConstraints = [
            updatesIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            updatesIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalMargin),
            updatesIndicator.heightAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            updatesIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
        ]
        
        // Left column
        if columns.contains(.overview) {
            contentConstraints += [
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
            ]
        }
        
        if columns.contains(.detail) {
            contentConstraints += [
                detailLabel.topAnchor.constraint(equalTo: middleColumnContentView.topAnchor,
                                                 constant: LayoutConstants.verticalMargin),
                detailLabel.leadingAnchor.constraint(equalTo: middleColumnContentView.leadingAnchor),
                detailLabel.trailingAnchor.constraint(equalTo: middleColumnContentView.trailingAnchor),
                detailLabel.bottomAnchor.constraint(equalTo: middleColumnContentView.bottomAnchor,
                                                    constant: -LayoutConstants.verticalMargin),
            ]
        }

        if columns.contains(.resources) {
            contentConstraints += [
                resourcesStackView.topAnchor.constraint(equalTo: rightColumnContentView.topAnchor, constant: LayoutConstants.verticalMargin),
                resourcesStackView.leadingAnchor.constraint(equalTo: rightColumnContentView.leadingAnchor),
                resourcesStackView.trailingAnchor.constraint(equalTo: rightColumnContentView.trailingAnchor),
                resourcesStackView.bottomAnchor.constraint(equalTo: rightColumnContentView.bottomAnchor),
            ]
        }
        
        NSLayoutConstraint.activate(contentConstraints)
    }
    
    // MARK: - Configuration
    
    public func decorate(with viewModel: TasksListItemViewModel) {
        // Left column
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        captionLabel.text = viewModel.caption
        
        priorityLabel.text = viewModel.badgeText
        priorityLabel.textColor = viewModel.badgeTextColor
        priorityLabel.backgroundColor = viewModel.badgeFillColor
        priorityLabel.borderColor = viewModel.badgeBorderColor
        priorityLabel.isHidden = viewModel.badgeText == nil
        
        updatesIndicator.isHidden = !viewModel.hasUpdates
        
        // Middle column
        
        detailLabel.text = viewModel.description
        
        // Right column
        
        setStatusRows(viewModel.resources)
        
        // Conditional display
        
        if viewModel.description != nil {
            columns.insert(.detail)
        } else {
            columns.remove(.detail)
        }

        if viewModel.hasResources {
            columns.insert(.resources)
        } else {
            columns.remove(.resources)
        }

        columnContainer.construct()
        addContentViewConstraints()
    }

    private func setStatusRows(_ viewModels: [TasksListItemResourceViewModel]?) {
        resourcesStackView.removeArrangedSubviewsFromViewHeirachy()
        
        guard let viewModels = viewModels, viewModels.count > 0 else {
            return
        }
        
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

extension TasksListItemCollectionViewCell: ColumnContainerViewDataSource {
    
    public func numberOfColumns(_ columnContainerView: ColumnContainerView) -> Int {
        return columns.count
    }
    
    public func columnInfo(_ columnContainerView: ColumnContainerView, at index: Int) -> ColumnInfo {
        if numberOfColumns(columnContainerView) == 1 {
            return ColumnInfo(minimumWidth: 200, maximumWidth: 1000)
        }
        
        return Column(rawValue: index)?.columnInfo ?? .zero
    }
    
    private func contentView(_ columnContainerView: ColumnContainerView, for column: Column?) -> UIView {
        guard let column = column else { return UIView() }
        switch column {
        case .overview:
            return leftColumnContentView
        case .detail:
            return middleColumnContentView
        case .resources:
            return rightColumnContentView
        }
    }
    
    public func viewForColumn(_ columnContainerView: ColumnContainerView, at index: Int) -> UIView {
        return contentView(columnContainerView, for: Column(rawValue: index))
    }
    
    public func columnSpacing(_ columnContainerView: ColumnContainerView) -> CGFloat {
        return LayoutConstants.columnSpacing
    }
}
