//
//  BookOnLandingViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class BookOnLandingViewModel {

    public init() {}

    open func convertCallsignsToViewModels() -> CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel> {
        // Just use all callsigns in patrol group for now
        var recentCallsigns: [BookOnLandingCallsignItemViewModel] = []
        for resource in CADStateManager.shared.resources {
            if resource.patrolGroup == CADStateManager.shared.patrolGroup {
                recentCallsigns.append(BookOnLandingCallsignItemViewModel(resource: resource))
            }
        }
        return CADFormCollectionSectionViewModel(title: "Recently Used Call Signs", items: recentCallsigns)
    }
    
    open func callsignSection() -> CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel> {
        return convertCallsignsToViewModels()
    }
    
    open func patrolAreaSection() -> CADFormCollectionSectionViewModel<BookOnLandingItemViewModel> {
        // TODO: Get dynamically
        return CADFormCollectionSectionViewModel(title: "Patrol Area",
                                                 items: [
                                                    BookOnLandingItemViewModel(title: CADStateManager.shared.patrolGroup,
                                                                             subtitle: nil,
                                                                             image:  AssetManager.shared.image(forKey: .location),
                                                                             imageColor: .brightBlue,
                                                                             imageBackgroundColor: nil)
            ]
        )
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return BookOnLandingViewController(viewModel: self)
    }

    /// Create the book on view controller for a selected callsign
    open func bookOnScreenForItem(_ callsignViewModel: BookOnLandingCallsignItemViewModel) -> Presentable {
        return BookOnScreen.bookOnDetailsForm(resource: callsignViewModel.resource, formSheet: false)
    }
    
    open func headerText() -> String? {
        return NSLocalizedString("You are not viewing all active tasks and resources.\nOnly booked on users can respond to tasks.", comment: "")
    }
    
    open func stayOffDutyButtonText() -> String {
        return NSLocalizedString("Stay Off Duty", comment: "")
    }
    
    open func allCallsignsButtonText() -> String {
        return NSLocalizedString("View All Call Signs", comment: "")
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Book On", comment: "Not Booked On title")
    }
    
    /// Content title shown when no results
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Call Signs Found", comment: "")
    }
    
    open func shouldShowExpandArrow() -> Bool {
        return false
    }
}
