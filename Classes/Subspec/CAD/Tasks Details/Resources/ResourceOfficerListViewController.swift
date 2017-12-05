//
//  ResourceOfficerListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewController: CADFormCollectionViewController<ResourceOfficerViewModel> {
    
    override public init(viewModel: CADFormCollectionViewModel<ResourceOfficerViewModel>) {
        super.init(viewModel: viewModel)
        
        sidebarItem.image = AssetManager.shared.image(forKey: .entityOfficer)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return OfficerCell.self
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: ResourceOfficerViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        
        let commsView = OfficerCommunicationsView(frame: CGRect(x: 0, y: 0, width: 72, height: 32),
                                                  commsEnabled: viewModel.commsEnabled)
        if traitCollection.horizontalSizeClass == .compact {
            cell.accessoryView = FormAccessoryView(style: .overflow)
        } else {
            cell.accessoryView = commsView
        }
        
        if let cell = cell as? OfficerCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.badgeLabel.text = viewModel.badgeText
        }
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.collectionView?.reloadData()
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return OfficerCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
}
