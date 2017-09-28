//
//  ActivityLogViewModel.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Internal view model for handling the sections of the collection view
private struct ActivityLogSectionViewModel {
    let title: String
    let items: [ActivityLogItemViewModel]
}

/// View model for the entire Activity Log view controller
public class ActivityLogViewModel {

    private var sections: [ActivityLogSectionViewModel] {
        return [
            ActivityLogSectionViewModel(title: "10:24 - Now: Assault - AS4205",
                                        items: [ActivityLogItemViewModel(title: "Status: At Incident [Assault - AS4205]",
                                                                         subtitle: "Jason Chieng, Herli Halim @ 188 Smith Street, Fitzroy VIC 3065",
                                                                         dotColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)),
                                                ActivityLogItemViewModel(title: "Status: Proceeding [Assault - AS4205]",
                                                                         subtitle: "Jason Chieng, Herli Halim",
                                                                         dotColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1))]),
            ActivityLogSectionViewModel(title: "10:17: Status Update",
                                        items: [ActivityLogItemViewModel(title: "Status: On Air",
                                                                         subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066",
                                                                         dotColor: #colorLiteral(red: 0.4, green: 0.6745098039, blue: 0.3568627451, alpha: 1))]),
            ActivityLogSectionViewModel(title: "09:16 - 10:14: Traffic Crash - AS4197",
                                        items: [ActivityLogItemViewModel(title: "Incident: Finalise [Traffic Crash - AS4197]",
                                                                         subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066",
                                                                         dotColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1))])
        ]
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

    // MARK: - Data Source

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

    // MARK: - Group Headers

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
