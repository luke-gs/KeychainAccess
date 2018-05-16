//
//  CreateIncidentStatusViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CreateIncidentStatusViewController: CADStatusViewController {
    
    open var createIncidentStatusViewModel: CreateIncidentStatusViewModel {
        return self.viewModel as! CreateIncidentStatusViewModel
    }
    
    // MARK: - Initializers
    
    public init(viewModel: CreateIncidentStatusViewModel) {
        super.init(viewModel: viewModel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath != createIncidentStatusViewModel.selectedIndexPath {
            
            let oldIndexPath = createIncidentStatusViewModel.selectedIndexPath
            
            createIncidentStatusViewModel.setSelectedIndexPath(indexPath)
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    collectionView.reloadItems(at: [indexPath, oldIndexPath].removeNils())
                }, completion: nil)
            }
        }
    }
    
}
