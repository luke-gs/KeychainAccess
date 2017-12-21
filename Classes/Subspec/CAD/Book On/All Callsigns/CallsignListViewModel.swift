//
//  CallsignListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewModel: CADFormCollectionViewModel<NotBookedOnCallsignItemViewModel> {

    private func convertCallsignsToViewModels() -> [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>] {
        var offDuty: [NotBookedOnCallsignItemViewModel] = []
        var bookedOn: [NotBookedOnCallsignItemViewModel] = []

        if let syncDetails = CADStateManager.shared.lastSync {
            for resource in syncDetails.resources {
                let viewModel = NotBookedOnCallsignItemViewModel(resource: resource)
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
    private lazy var viewModels: [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>] = {
        return convertCallsignsToViewModels()
    }()

    public override init() {
        super.init()
        sections = sortedSections(from: viewModels)
    }
    
    /// Create the book on view controller for a selected callsign
    open func bookOnViewControllerForItem(_ indexPath: IndexPath) -> UIViewController? {
        if let itemViewModel = item(at: indexPath) {
            return BookOnDetailsFormViewModel(callsignViewModel: itemViewModel).createViewController()
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
        return NSLocalizedString("No Callsigns Found", comment: "")
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
            } as [NotBookedOnCallsignItemViewModel?]).removeNils()
            
            // Return the section if items were found
            if filteredItems.count > 0 {
                return CADFormCollectionSectionViewModel(title: section.title, items: filteredItems)
            }
            
            return nil
        } as [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>?]).removeNils()
        
        sections = filteredData
    }
    
    
    /// Sorts sections, showing `On Air` status first, then `At Incident` status, then alphabetically by callsign
    ///
    /// - Parameter unsorted: the unsorted array
    /// - Returns: a sorted array
    open func sortedSections(from unsorted: [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>]) -> [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>] {
        // Map sections
        return unsorted.map { section in
            // Sort items
            let sortedItems = section.items.sorted {
                if $0.status == "On Air" && $0.status != $1.status {
                    // Status is on air, and statuses don't match
                    return true
                } else if $0.status == "At Incident" && $0.status != $1.status {
                    // Statuses don't match, first is at incident. Prioritise if second is not on air
                    return $1.status != "On Air"
                } else {
                    // Status matches, sort alphabetically by callsign
                    return $0.callsign < $1.callsign
                }
            }
            
            return CADFormCollectionSectionViewModel(title: section.title, items: sortedItems)
        }
    }
}
