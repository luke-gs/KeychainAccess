//
//  IncidentAssociationsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationsViewController: CADFormCollectionViewController<EntitySummaryDisplayable> {
    
    override public init(viewModel: CADFormCollectionViewModel<EntitySummaryDisplayable>) {
        super.init(viewModel: viewModel)
        
        // TODO: Get real image
        sidebarItem.image = AssetManager.shared.image(forKey: .association)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return EntityListCollectionViewCell.self
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: EntitySummaryDisplayable) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.accessoryView = nil
        
        if let cell = cell as? EntityListCollectionViewCell {
            cell.decorate(with: viewModel)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let _ = viewModel.item(at: indexPath) {
            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
        return 0
    }

}
