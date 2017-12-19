//
//  TasksListResourceCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListResourceCollectionViewCell: CollectionViewFormCell {

    enum Column: Int {
        case summary = 0
        case incident = 1
        case information = 2
        
        var columnInfo: ColumnInfo {
            switch self {
            case .summary:
                return ColumnInfo(minimumWidth: 200, maximumWidth: 200)
            case .incident:
                return ColumnInfo(minimumWidth: 200, maximumWidth: 280)
            case .information:
                return ColumnInfo(minimumWidth: 200, maximumWidth: 1000)
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
    
    /// Container for the columns
    private let columnContainer = ColumnContainerView()
    
    /// View for showing updates indicator
    open let updatesIndicator = UIImageView()
    
    /// View for summary column
    open let summaryView = TasksListResourceSummaryView()
    
    /// View for incident
    open let incidentView = TasksListIncidentSummaryView()
    
    /// View for status rows
    open let informationRowView = TasksListInfoRowStackView(maxViews: 3)
    
    // MARK: - Properties
    
    /// Columns to show
    private var columns: Set<Column> = [.summary]
    
    open override func commonInit() {
        super.commonInit()
        columnContainer.dataSource = self
        setupViews()
    }
    
    /// Creates and styles views
    private func setupViews() {
        contentView.addSubview(columnContainer)
        columnContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Hide updates indicator by default
        updatesIndicator.isHidden = true
        updatesIndicator.image = UIImage.statusDot(withColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1))
        updatesIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(updatesIndicator)
        
        NSLayoutConstraint.activate([
            columnContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            columnContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor,
                                                      constant: -LayoutConstants.accessorySize),
            columnContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            columnContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            updatesIndicator.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 10),
            updatesIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalMargin),
            updatesIndicator.heightAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
            updatesIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize),
        ])
    }
    
    // MARK: - Configuration
    
    open func decorate(with viewModel: TasksListResourceViewModel) {
        // Left column
        
        summaryView.resourceImageView.image = viewModel.resourceImage
        summaryView.titleLabel.text = viewModel.title
        summaryView.subtitleLabel.text = viewModel.subtitle
        summaryView.captionLabel.text = viewModel.caption
        summaryView.statusImageView.image = viewModel.statusImage

        summaryView.priorityLabel.text = viewModel.incidentViewModel?.badgeText
        summaryView.priorityLabel.textColor = viewModel.incidentViewModel?.badgeTextColor
        summaryView.priorityLabel.backgroundColor = viewModel.incidentViewModel?.badgeFillColor
        summaryView.priorityLabel.borderColor = viewModel.incidentViewModel?.badgeBorderColor
        summaryView.priorityLabel.isHidden = viewModel.incidentViewModel?.badgeText == nil
        
        // Middle column
        
        incidentView.titleLabel.text = viewModel.incidentViewModel?.title
        incidentView.subtitleLabel.text = viewModel.incidentViewModel?.subtitle
        incidentView.captionLabel.text = viewModel.incidentViewModel?.caption
        
        incidentView.priorityLabel.text = viewModel.incidentViewModel?.badgeText
        incidentView.priorityLabel.textColor = viewModel.incidentViewModel?.badgeTextColor
        incidentView.priorityLabel.backgroundColor = viewModel.incidentViewModel?.badgeFillColor
        incidentView.priorityLabel.borderColor = viewModel.incidentViewModel?.badgeBorderColor
        incidentView.priorityLabel.isHidden = viewModel.incidentViewModel?.badgeText == nil
        
        // Right column
        
        informationRowView.setRows(viewModel.informationRows)
        
        // Conditional display
        
        if viewModel.incidentViewModel != nil {
            columns.insert(.incident)
        } else {
            columns.remove(.incident)
        }

        if viewModel.hasInformationRows {
            columns.insert(.information)
        } else {
            columns.remove(.information)
        }
        
        columnContainer.construct()
    }
    
    open func apply(theme: Theme) {
        summaryView.titleLabel.textColor = theme.color(forKey: .primaryText)
        summaryView.subtitleLabel.textColor = theme.color(forKey: .primaryText)
        summaryView.captionLabel.textColor = theme.color(forKey: .secondaryText)
        summaryView.statusImageView.tintColor = theme.color(forKey: .secondaryText)

        incidentView.titleLabel.textColor = theme.color(forKey: .primaryText)
        incidentView.subtitleLabel.textColor = theme.color(forKey: .primaryText)
        incidentView.captionLabel.textColor = theme.color(forKey: .secondaryText)
    }
    
    open override var bounds: CGRect {
        didSet {
            // This could be done better...
            if bounds.width <= Column.summary.columnInfo.minimumWidth + Column.information.columnInfo.minimumWidth {
                // If space doesn't allow for info column, show the summary priority label if we have text for it
                summaryView.priorityLabel.isHidden = summaryView.priorityLabel.text == nil
                // Hide the status image if we only have one column
                summaryView.statusImageView.isHidden = true
            } else {
                // Info column should fit, hide summary priority label
                summaryView.priorityLabel.isHidden = true
                
                // Show the status image if it exists
                summaryView.statusImageView.isHidden = summaryView.statusImageView.image == nil
            }
        }
    }
}

extension TasksListResourceCollectionViewCell: ColumnContainerViewDataSource {
    
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
        case .summary:
            return summaryView
        case .incident:
            return incidentView
        case .information:
            return informationRowView
        }
    }
    
    public func viewForColumn(_ columnContainerView: ColumnContainerView, at index: Int) -> UIView {
        return contentView(columnContainerView, for: Column(rawValue: index))
    }
    
    public func columnSpacing(_ columnContainerView: ColumnContainerView) -> CGFloat {
        return LayoutConstants.columnSpacing
    }
}
