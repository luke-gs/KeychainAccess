//
//  CallsignListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
open class CallsignListViewModel: CADFormCollectionViewModel<BookOnLandingCallsignItemViewModel> {

    open func convertCallsignsToViewModels() -> [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>] {
        var offDuty: [BookOnLandingCallsignItemViewModel] = []
        var bookedOn: [BookOnLandingCallsignItemViewModel] = []

        for resource in CADStateManager.shared.resources {
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

    /// Sorts sections based on resource status, then alphabetically by callsign
    ///
    /// - Parameter unsorted: The unsorted array
    /// - Returns: A sorted array
    open func sortedSections(from unsorted: [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>]) -> [CADFormCollectionSectionViewModel<BookOnLandingCallsignItemViewModel>] {
        // Map sections
        return unsorted.map { section in
            // Sort items
            let sortedItems = section.items.sorted { (lhs, rhs) in
                if lhs.status?.listOrder != rhs.status?.listOrder {
                    // Sort by lower list order
                    return lhs.status?.listOrder ?? Int.max < rhs.status?.listOrder ?? Int.max
                }
                // Sort alphabetically by callsign
                return lhs.callsign < rhs.callsign
            }
            return CADFormCollectionSectionViewModel(title: section.title, items: sortedItems)
        }
    }
}
