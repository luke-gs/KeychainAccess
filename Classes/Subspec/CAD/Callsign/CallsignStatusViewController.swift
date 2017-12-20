//
//  CallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class CallsignStatusViewController: CADStatusViewController {

    open let viewModel: CallsignStatusViewModel
    
    /// The index path that is currently loading
    private var loadingIndexPath: IndexPath?
    
    // MARK: - Initializers

    public init(viewModel: CallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ManageCallsignStatusViewCell else { return }
        cell.isLoading = indexPath == loadingIndexPath
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != viewModel.selectedIndexPath, loadingIndexPath == nil {

            let oldIndexPath = viewModel.selectedIndexPath
            set(loading: true, at: indexPath)

            firstly {
                // Attempt to change state
                return viewModel.setSelectedIndexPath(indexPath)
            }.then { _ in
                // Update selection
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath, oldIndexPath].removeNils())
                    }, completion: nil)
                }
            }.always {
                // Stop animation
                self.set(loading: false, at: indexPath)
            }.catch { error in
                AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Internal
    
    private func set(loading: Bool, at indexPath: IndexPath) {
        self.loadingIndexPath = loading ? indexPath : nil
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
}
