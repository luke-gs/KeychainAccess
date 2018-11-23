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
    public var items: [EventListItemViewModelable]
    public var actionButtonTitle: String?
    public var actionButtonHandler: ((UIButton) -> Void)?
    public var isExpanded: Bool
    public var useCards: Bool

    init(title: String?, items: [EventListItemViewModelable], actionButtonTitle: String? = nil, actionButtonHandler: ((UIButton) -> Void)? = nil, isExpanded: Bool, useCards: Bool) {
        self.title = title
        self.items = items
        self.actionButtonTitle = actionButtonTitle
        self.actionButtonHandler = actionButtonHandler
        self.isExpanded = isExpanded
        self.useCards = useCards
    }

    public func displayMode(for traitCollection: UITraitCollection) -> EventListSectionDisplayMode {
        // Use cards if set and have space
        return traitCollection.horizontalSizeClass == .compact ? .list : (useCards ? .cards : .list)
    }
}
