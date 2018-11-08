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
        let recentCallsignIds: [String] = UserPreferenceManager.shared.preference(for: .recentCallsigns)?.codables() ?? []

        let recentCallsigns = recentCallsignIds.compactMap { id -> BookOnLandingCallsignItemViewModel? in
            if let resource = CADStateManager.shared.resourcesById[id],
                resource.patrolGroup == CADStateManager.shared.patrolGroup {
                return BookOnLandingCallsignItemViewModel(resource: resource)
            }
            return nil
        }

        return CADFormCollectionSectionViewModel(title: "Recently Used Call Signs", items: recentCallsigns)
    }

    open func callsignSection() -> CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel> {
        return convertCallsignsToViewModels()
    }

    open func patrolAreaSection() -> CADFormCollectionSectionViewModel<BookOnLandingItemViewModel> {
        return CADFormCollectionSectionViewModel(title: patrolAreaSectionText(),
                                                 items: [
                                                    BookOnLandingItemViewModel(title: CADStateManager.shared.patrolGroup ?? noPatrolAreaSelectedText(),
                                                                             subtitle: nil,
                                                                             image: AssetManager.shared.image(forKey: .location),
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

    open func noPatrolAreaSelectedText() -> String {
        return NSLocalizedString("Select Patrol Group", comment: "")
    }

    open func patrolAreaSectionText() -> String {
        return NSLocalizedString("Patrol Group", comment: "")
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

    open func callsignCellClass() -> (CollectionViewFormCell & DefaultReusable).Type {
        return CallsignCollectionViewCell.self
    }

    /// Decorates a cell with the view model
    open func decorate(cell: CollectionViewFormCell, with viewModel: BookOnLandingCallsignItemViewModel) {
        if let cell = cell as? CallsignCollectionViewCell {
            cell.decorate(with: viewModel)
        }
    }

    /// Applies theme to a cell
    open func apply(theme: Theme, to cell: CollectionViewFormCell) {
        if let cell = cell as? CallsignCollectionViewCell {
            cell.apply(theme: theme)
        }
    }

}
