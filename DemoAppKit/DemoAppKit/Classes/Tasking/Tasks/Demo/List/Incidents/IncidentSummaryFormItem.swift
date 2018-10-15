//
//  IncidentSummaryFormItem.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/3/18.
//

import UIKit

public class IncidentSummaryFormItem: BaseFormItem {

    // Weak reference to view model owned by parent view controller
    public weak var viewModel: TasksListIncidentViewModel?
    
    public init(viewModel: TasksListIncidentViewModel) {
        self.viewModel = viewModel
        super.init(cellType: TasksListIncidentCollectionViewCell.self, reuseIdentifier: TasksListIncidentCollectionViewCell.defaultReuseIdentifier)
        
        highlightStyle = .fade
    }
    
    public override func configure(_ cell: CollectionViewFormCell) {
        if let viewModel = viewModel {
            let cell = cell as! TasksListIncidentCollectionViewCell
            cell.decorate(with: viewModel)
        }
    }

    public override func intrinsicWidth(in collectionView: UICollectionView, layout: CollectionViewFormLayout, sectionEdgeInsets: UIEdgeInsets, for traitCollection: UITraitCollection) -> CGFloat {
        return collectionView.bounds.width
    }
    
    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, givenContentWidth contentWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        return 64
    }

}

// MARK: - Chaining methods

extension IncidentSummaryFormItem {
    
    @discardableResult
    public func viewModel(_ viewModel: TasksListIncidentViewModel) -> Self {
        self.viewModel = viewModel
        return self
    }
}
