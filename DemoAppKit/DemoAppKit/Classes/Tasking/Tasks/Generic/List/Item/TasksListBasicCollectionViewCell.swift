//
//  TasksListBasicCollectionViewCell.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A basic cell for the tasks list with 2 columns – a summary view and a description label.
open class TasksListBasicCollectionViewCell: CollectionViewFormCell {
    enum Column: Int {
        case summary = 0
        case detail = 1

        var columnInfo: ColumnInfo {
            switch self {
            case .summary:
                return ColumnInfo(minimumWidth: 200, maximumWidth: 280)
            case .detail:
                return ColumnInfo(minimumWidth: 300, maximumWidth: 1000)
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
    public let updatesIndicator = UIImageView()

    /// View for summary column
    public let summaryView = TasksListBasicSummaryView()

    /// View for details
    public let detailView = TasksListDetailView()

    // MARK: - Properties

    /// Columns to show
    private var columns: Set<Column> = [.summary, .detail]

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
            updatesIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.updatesIndicatorSize)
        ])
    }

    // MARK: - Configuration

    open func decorate(with viewModel: TasksListBasicViewModel) {
        // Left column

        summaryView.titleLabel.text = viewModel.title
        summaryView.subtitleLabel.text = viewModel.subtitle
        summaryView.captionLabel.text = viewModel.caption

        updatesIndicator.isHidden = !viewModel.hasUpdates

        // Middle column
        detailView.detailLabel.text = viewModel.description

        columnContainer.construct()
    }

    open func apply(theme: Theme) {
        summaryView.titleLabel.textColor = theme.color(forKey: .primaryText)
        summaryView.subtitleLabel.textColor = theme.color(forKey: .primaryText)
        summaryView.captionLabel.textColor = theme.color(forKey: .secondaryText)
    }

}

extension TasksListBasicCollectionViewCell: ColumnContainerViewDataSource {

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
        case .detail:
            return detailView
        }
    }

    public func viewForColumn(_ columnContainerView: ColumnContainerView, at index: Int) -> UIView {
        return contentView(columnContainerView, for: Column(rawValue: index))
    }

    public func columnSpacing(_ columnContainerView: ColumnContainerView) -> CGFloat {
        return LayoutConstants.columnSpacing
    }
}
