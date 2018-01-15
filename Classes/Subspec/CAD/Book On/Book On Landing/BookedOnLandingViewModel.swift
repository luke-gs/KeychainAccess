//
//  BookedOnLandingViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class BookedOnLandingViewModel {

    public init() {}

    open func convertCallsignsToViewModels() -> CADFormCollectionSectionViewModel<BookedOnLandingCallsignItemViewModel> {
        // Just use all callsigns for now
        var recentCallsigns: [BookedOnLandingCallsignItemViewModel] = []
        if let syncDetails = CADStateManager.shared.lastSync {
            for resource in syncDetails.resources {
                recentCallsigns.append(BookedOnLandingCallsignItemViewModel(resource: resource))
            }
        }
        return CADFormCollectionSectionViewModel(title: "Recently Used Call Signs", items: recentCallsigns)
    }
    
    open func callsignSection() -> CADFormCollectionSectionViewModel<BookedOnLandingCallsignItemViewModel> {
        return convertCallsignsToViewModels()
    }
    
    open func patrolAreaSection() -> CADFormCollectionSectionViewModel<BookedOnLandingItemViewModel> {
        // TODO: Get dynamically
        return CADFormCollectionSectionViewModel(title: "Patrol Area",
                                                 items: [
                                                    BookedOnLandingItemViewModel(title: CADStateManager.shared.patrolGroup,
                                                                             subtitle: nil,
                                                                             image:  AssetManager.shared.image(forKey: .location),
                                                                             imageColor: .brightBlue,
                                                                             imageBackgroundColor: nil)
            ]
        )
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return BookedOnLandingViewController(viewModel: self)
    }

    /// Create the book on view controller for a selected callsign
    open func bookOnScreenForItem(_ callsignViewModel: BookedOnLandingCallsignItemViewModel) -> Presentable {
        return BookOnScreen.bookOnDetailsForm(callsignViewModel: callsignViewModel)
    }
    
    open func headerText() -> String? {
        return NSLocalizedString("You are not viewing all active tasks and resources.\nOnly booked on users can respond to tasks.", comment: "")
    }
    
    open func stayOffDutyButtonText() -> String? {
        return NSLocalizedString("Stay Off Duty", comment: "")
    }
    
    open func allCallsignsButtonText() -> String? {
        return NSLocalizedString("View All Call Signs", comment: "")
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("You are not booked on", comment: "Not Booked On title")
    }
    
    /// Content title shown when no results
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Call Signs Found", comment: "")
    }
    
    open func shouldShowExpandArrow() -> Bool {
        return false
    }
}
