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
        let items = eventsManager.displayables.compactMap { $0 as? EventListItemViewModel }
        let draftItems = items.filter { $0.isDraft }
        let queuedItems = items.filter { !$0.isDraft }

        let sections = [
            EventListSectionViewModel(title: AssetManager.shared.string(forKey: .eventsDraftSectionTitle),
                                      isExpanded: true,
                                      items: draftItems,
                                      useCards: true),
            EventListSectionViewModel(title: AssetManager.shared.string(forKey: .eventsQueuedSectionTitle),
                                      isExpanded: true,
                                      items: queuedItems,
                                      useCards: false)
        ]
        // Only show sections with items
        self.sections = sections.filter { $0.items.count > 0 }
    }

}

extension EventListViewModel: EventsManagerDelegate {
    public func eventsManagerDidUpdate(_ eventsManager: EventsManager) {
        updateSections()
    }
}
