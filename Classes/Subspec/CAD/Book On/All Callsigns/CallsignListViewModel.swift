//
//  CallsignListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewModel: CADFormCollectionViewModel<BookOnLandingCallsignItemViewModel> {

    private func convertCallsignsToViewModels() -> [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>] {
        var offDuty: [BookOnLandingCallsignItemViewModel] = []
        var bookedOn: [BookOnLandingCallsignItemViewModel] = []

        let resources = Array(CADStateManager.shared.resourcesById.values)
        for resource in resources {
            if resource.patrolGroup == CADStateManager.shared.patrolGroup {
                let viewModel = BookOnLandingCallsignItemViewModel(resource: resource)
                if resource.shiftStart == nil {
                    offDuty.append(viewModel)
                } else {
                    bookedOn.append(viewModel)
                }
            }
        }
        return [CADFormCollectionSectionViewModel(title: "\(offDuty.count) Off Duty", items: offDuty),
                CADFormCollectionSectionViewModel(title: "\(bookedOn.count) Booked On", items: bookedOn)]

    }
    private lazy var viewModels: [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>] = {
        return convertCallsignsToViewModels()
    }()

    public override init() {
        super.init()
        sections = sortedSections(from: viewModels)
    }
    
    /// Create the book on view controller for a selected callsign
    open func bookOnScreenForItem(_ indexPath: IndexPath) -> Presentable? {
        if let itemViewModel = item(at: indexPath) {
            return BookOnScreen.bookOnDetailsForm(resource: itemViewModel.resource, formSheet: false)
        }
        return nil
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> CallsignListViewController {
        return CallsignListViewController(viewModel: self)
    }
    
    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String? {
        return [NSLocalizedString("Patrol Area", comment: ""), CADStateManager.shared.officerDetails?.patrolGroup].joined(separator: ": ")
    }
    
    // MARK: - Override
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Select Call Sign", comment: "")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Call Signs Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    
    
    /// Applies the search filter with the specified text, and updates the `sections`
    /// array to match. If no results found, an empty array will be set for `sections`.
    open func applyFilter(withText text: String?) {
        guard let text = text, text.count > 0 else {
            sections = viewModels
            return
        }
        
        // Map sections
        let filteredData = (viewModels.map { section in
            // Map items
            let filteredItems = (section.items.map { item in
                // Map if title contains case-insensitive match
                if item.title.lowercased().contains(text.lowercased()) {
                    return item
                }
                return nil
            } as [BookOnLandingCallsignItemViewModel?]).removeNils()
            
            // Return the section if items were found
            if filteredItems.count > 0 {
                return CADFormCollectionSectionViewModel(title: section.title, items: filteredItems)
            }
            
            return nil
        } as [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>?]).removeNils()
        
        sections = filteredData
    }
    
    
    /// Sorts sections, showing `On Air` status first, then `At Incident` status, then alphabetically by callsign
    /// NOTE: Method should be overridden for clients with different resource statuses
    ///
    /// - Parameter unsorted: the unsorted array
    /// - Returns: a sorted array
    open func sortedSections(from unsorted: [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>]) -> [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>] {
        // Map sections
        return unsorted.map { section in
            // Sort items
            let sortedItems = section.items.sorted { (lhs, rhs) in
                if lhs.status != rhs.status {
                    // TODO: move to client kit
                    // Status is not same, check if either is On Air, or At Incident
                    /*
                    if lhs.status == ResourceStatusCore.onAir || rhs.status == ResourceStatusCore.onAir {
                        return lhs.status == ResourceStatusCore.onAir
                    } else if lhs.status == ResourceStatusCore.atIncident || rhs.status == ResourceStatusCore.atIncident {
                        return lhs.status == ResourceStatusCore.atIncident
                    }
 */
                }
                // Sort alphabetically by callsign
                return lhs.callsign < rhs.callsign
            }
            return CADFormCollectionSectionViewModel(title: section.title, items: sortedItems)
        }
    }
}
