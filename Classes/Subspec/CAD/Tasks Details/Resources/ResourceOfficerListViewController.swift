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
        
        // TODO: Get real image
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
        cell.accessoryView = nil
        
        if let cell = cell as? OfficerCell {
            let (messageEnabled, callEnabled, videoEnabled) = viewModel.commsEnabled
            
            cell.messageButton.isEnabled = messageEnabled
            cell.callButton.isEnabled = callEnabled
            cell.videoButton.isEnabled = videoEnabled
            
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.badgeLabel.text = viewModel.badgeText
        }
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
