//
//  NotBookedOnViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class NotBookedOnViewModel: CADFormCollectionViewModel<NotBookedOnItemViewModel> {

    private func convertCallsignsToViewModels() -> CADFormCollectionSectionViewModel<NotBookedOnItemViewModel> {
        // Just use all callsigns for now
        var recentCallsigns: [NotBookedOnCallsignItemViewModel] = []
        if let syncDetails = CADStateManager.shared.lastSync {
            for resource in syncDetails.resources {
                recentCallsigns.append(NotBookedOnCallsignItemViewModel(resource: resource))
            }
        }
        return CADFormCollectionSectionViewModel(title: "Recently Used Callsigns", items: recentCallsigns)
    }

    public override init() {
        super.init()
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Patrol Area",
                                              items: [
                                                NotBookedOnItemViewModel(title: "Collingwood",
                                                                         subtitle: "9 Callsigns",
                                                                         image:  AssetManager.shared.image(forKey: .location),
                                                                         imageColor: .brightBlue,
                                                                         imageBackgroundColor: nil)
                ]
            ),
            convertCallsignsToViewModels()
        ]
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return NotBookedOnViewController(viewModel: self)
    }

    /// Create the book on view controller for a selected callsign
    open func bookOnViewControllerForItem(_ indexPath: IndexPath) -> UIViewController? {
        if let itemViewModel = item(at: indexPath) as? NotBookedOnCallsignItemViewModel {
            return BookOnDetailsFormViewModel(callsignViewModel: itemViewModel).createViewController()
        }
        return nil
    }
    
    open func headerText() -> String? {
        return NSLocalizedString("You are not viewing all active tasks and resources.\nOnly booked on users can respond to tasks.", comment: "")
    }
    
    open func stayOffDutyButtonText() -> String? {
        return NSLocalizedString("Stay Off Duty", comment: "")
    }
    
    open func allCallsignsButtonText() -> String? {
        return NSLocalizedString("View All Callsigns", comment: "")
    }
    
    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("You are not booked on", comment: "Not Booked On title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Callsigns Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }
    
}
