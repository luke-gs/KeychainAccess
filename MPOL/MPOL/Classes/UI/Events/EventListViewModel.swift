//
//  EventListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

// PSCore demo app implementation of event list view model
public class EventListViewModel: EventListViewModelable {

    /// Delegate for observing changes to view model
    public weak var delegate: EventListViewModelableDelegate?

    /// The events eventsManager
    public let eventsManager: EventsManager

    /// Handler for creating a new item
    public var creationHandler: (() -> Void)?

    /// Handler for selecting an item
    public var selectionHandler: ((EventListItemViewModelable) -> Void)?

    public init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
        self.eventsManager.delegate = self

        self.updateSections()
    }

    // MARK: Screen

    public var navTitle: String? {
        return NSLocalizedString("Events", comment: "")
    }

    public var noContentTitle: String? {
        return NSLocalizedString("No Events", comment: "")
    }

    public var noContentSubtitle: String? {
        return NSLocalizedString("You have no Current or Queued Events", comment: "")
    }

    public var noContentButtonText: String? {
        return NSLocalizedString("Create new Event", comment: "")
    }

    public var noContentImage: UIImage? {
        return AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
    }

    public var rightNavBarButtonItemText: String? {
        return NSLocalizedString("New Event", comment: "")
    }

    public var tabBarImageSet: (image: UIImage?, selectedImage: UIImage?)? {
        return (image: AssetManager.shared.image(forKey: .tabBarEvents), selectedImage: AssetManager.shared.image(forKey: .tabBarEventsSelected))
    }

    // MARK: Items

    public var sections: [EventListSectionViewModelable] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }

    public func createNewItem() {
        creationHandler?()
    }

    public func selectItem(_ item: EventListItemViewModelable) {
        selectionHandler?(item)
    }

    public func deleteItem(_ item: EventListItemViewModelable) {
        try? eventsManager.remove(for: item.id)
    }

    public var badgeCountString: String? {
        let count = eventsManager.events.count
        if count > 0 {
            return "\(count)"
        } else {
            return nil
        }
    }

    // MARK: Private

    private func updateSections() {
        let allDisplayables = eventsManager.displayables
        let draftItems = allDisplayables.filter { ($0 as! EventListItemViewModel).isDraft }
        let queuedItems = allDisplayables.filter { !($0 as! EventListItemViewModel).isDraft }

        sections = [
            EventListSectionViewModel(title: AssetManager.shared.string(forKey: .draftSectionTitle), isExpanded: true, items: draftItems, useCards: true),
            EventListSectionViewModel(title: "Queued", isExpanded: true, items: queuedItems, useCards: false)
        ]
    }

}

extension EventListViewModel: EventsManagerDelegate {
    public func eventsManagerDidUpdate(_ eventsManager: EventsManager) {
        updateSections()
    }
}

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
