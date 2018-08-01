//
//  AlertsFormItem.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class AlertsFormItem: BaseFormItem {

    public var dataSource: SearchAlertsViewModelable?
    public weak var delegate: SearchAlertsDelegate?

    // Allow for customisation of the empty state
    public var emptyStateContents: EmptyStateContents?

    public init() {
        super.init(cellType: CollectionViewFormAlertsCell.self, reuseIdentifier: CollectionViewFormAlertsCell.defaultReuseIdentifier)
        separatorStyle = .none
    }

    public override func configure(_ cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormAlertsCell else { return }
        cell.dataSource = dataSource
        cell.delegate = delegate
        cell.loadingManager.noContentView.titleLabel.text = emptyStateContents?.title
        cell.loadingManager.noContentView.subtitleLabel.text = emptyStateContents?.subtitle
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormAlertsCell.intrinsicHeight
    }

    open override func apply(theme: Theme, toCell cell: CollectionViewFormCell) {
        guard let cell = cell as? CollectionViewFormAlertsCell else { return }
        cell.loadingManager.noContentView.titleLabel.textColor = theme.color(forKey: .headerTitleText)
        cell.loadingManager.noContentView.subtitleLabel.textColor = theme.color(forKey: .headerSubtitleText)
    }
}

public protocol SearchAlertsViewModelable: class {
    var alertEntities: [Entity] { get }
    var summaryDisplayFormatter: EntitySummaryDisplayFormatter { get }
}

public protocol SearchAlertsDelegate: class {
    func didSelectEntity(at index: Int)
}
