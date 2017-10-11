//
//  MapFilterViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 4/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The map layer filter list
open class MapFilterViewController: FormCollectionViewController {

    private var viewModel: TasksMapFilterViewModel
    
    public init(with viewModel: TasksMapFilterViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Layers", comment: "Layers")
        calculatesContentHeight = true
        
        collectionView?.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView?.register(CollectionViewFormSubtitleCell.self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFilters()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        // Set cell title and checkmark state
        cell.titleLabel.text = viewModel.titleForItem(at: indexPath)
        cell.accessoryView = viewModel.isChecked(at: indexPath) ? FormAccessoryView(style: .checkmark) : nil
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? CollectionViewFormSubtitleCell {
            // Set text colour here as it is overriden in superclass
            cell.titleLabel.textColor = viewModel.textColor(at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // Create section header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = NSLocalizedString("Show", comment: "Show Filters")
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.toggleItem(at: indexPath)
        
        // Don't use the default fade animation for cell reloading
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let title = viewModel.titleForItem(at: indexPath) {
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: nil, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}
