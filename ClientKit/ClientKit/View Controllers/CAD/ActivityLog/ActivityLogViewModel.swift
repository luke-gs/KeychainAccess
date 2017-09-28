//
//  ActivityLogViewModel.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

private struct ActivityLogSectionViewModel {
    let title: String
    let items: [ActivityLogItemViewModel]
}

public class ActivityLogViewModel {

    private var sections: [ActivityLogSectionViewModel] {
        return [
            ActivityLogSectionViewModel(title: "10:24 - Now: Assault - AS4205",
                                        items: [ActivityLogItemViewModel(title: "Status: At Incident [Assault - AS4205]",
                                                                         subtitle: "Jason Chieng, Herli Halim @ 188 Smith Street, Fitzroy VIC 3065"),
                                                ActivityLogItemViewModel(title: "Status: Proceeding [Assault - AS4205]",
                                                                         subtitle: "Jason Chieng, Herli Halim")]),
            ActivityLogSectionViewModel(title: "10:17: Status Update",
                                        items: [ActivityLogItemViewModel(title: "Status: On Air",
                                                                         subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066")])
        ]
//        didSet {
//            let state: LoadingStateManager.State = sections.isEmpty ? .noContent : .loaded
//            delegate?.updateLoadingState(state)
//            delegate?.reloadData()
//        }
    }

    private var collapsedSections: Set<Int> = []

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Activity Log", comment: "Activity Log navigation title")
    }

    /// Content title shown when no results
    public func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }

    public func noContentSubtitle() -> String? {
        return nil
    }

    public func numberOfSections() -> Int {
        return sections.count
    }

    public func numberOfItems(for section: Int) -> Int {
        if let sectionViewModel = sections[ifExists: section], !collapsedSections.contains(section) {
            return sectionViewModel.items.count
        }
        return 0
    }

    public func item(at indexPath: IndexPath) -> ActivityLogItemViewModel? {
        if let sectionViewModel = sections[ifExists: indexPath.section] {
            return sectionViewModel.items[ifExists: indexPath.row]
        }
        return nil
    }

    public func isHeaderExpanded(at section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }

    public func toggleHeaderExpanded(at section: Int) {
        if let itemIndex = collapsedSections.index(of: section) {
            collapsedSections.remove(at: itemIndex)
        } else {
            collapsedSections.insert(section)
        }
    }

    public func headerText(at section: Int) -> String? {
        if let sectionViewModel = sections[ifExists: section] {
            return sectionViewModel.title
        }
        return nil
    }
}
