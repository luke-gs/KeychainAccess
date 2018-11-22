//
//  EventListSectionViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

// PSCore demo app implementation of event list section view model
public class EventListSectionViewModel: EventListSectionViewModelable {
    public var title: String?
    public var isExpanded: Bool
    public var items: [EventListItemViewModelable]
    public var useCards: Bool

    public init(title: String?, isExpanded: Bool, items: [EventListItemViewModelable], useCards: Bool) {
        self.title = title
        self.isExpanded = isExpanded
        self.items = items
        self.useCards = useCards
    }

    public func displayMode(for traitCollection: UITraitCollection) -> EventListSectionDisplayMode {
        // Use cards if set and have space
        return traitCollection.horizontalSizeClass == .compact ? .list : useCards ? .cards : .list
    }
}
