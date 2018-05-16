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

    open var callsignViewModel: CallsignStatusViewModel {
        return self.viewModel as! CallsignStatusViewModel
    }
    
    // MARK: - Initializers

    public init(viewModel: CallsignStatusViewModel) {
        super.init(viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - UICollectionViewDelegate

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != callsignViewModel.selectedIndexPath {

            firstly {
                // Attempt to change state
                return callsignViewModel.setSelectedIndexPath(indexPath)
            }.done { [weak self] _ in
                // Reload the collection view to show new selection. The manage callsign view will update
                // in response to the callsign being changed, but the incident popover wont
                self?.reloadForm()
            }.catch { error in
                AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
}
