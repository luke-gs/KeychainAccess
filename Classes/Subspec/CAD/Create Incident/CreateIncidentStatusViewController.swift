//
//  CreateIncidentStatusViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CreateIncidentStatusViewController: CADStatusViewController {
    
    private let viewModel: CreateIncidentStatusViewModel
    
    // MARK: - Initializers
    
    public init(viewModel: CreateIncidentStatusViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath != viewModel.selectedIndexPath {
            
            let oldIndexPath = viewModel.selectedIndexPath
            
            viewModel.setSelectedIndexPath(indexPath)
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    collectionView.reloadItems(at: [indexPath, oldIndexPath].removeNils())
                }, completion: nil)
            }
        }
    }
    
}
