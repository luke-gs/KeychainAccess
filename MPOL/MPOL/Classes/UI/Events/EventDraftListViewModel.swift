//
//  EventDraftListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class EventDraftListViewModel: EventListViewModelable {

    private let manager: EventsManager

    public var draftCount: Int {
        return manager.draftItems.count
    }

    public func draftItem(for index: Int) -> Draftable? {
        if index >= 0 && index < manager.draftItems.count {
            return manager.draftItems[index]
        }
        return nil
    }

    public func deleteDraftItem(at index: Int, with id: String) {
        manager.deleteDraftItem(at: index, with: id)
    }

    public var badgeCountString: String? {
        let count = manager.draftItems.count
        if count > 0 {
            return "\(count)"
        } else {
            return nil
        }
    }

    public init(manager: EventsManager) {
        self.manager = manager
    }

    public var title: String? {
        return "Events"
    }

    public var noContentTitle: String? {
        return "No Events"
    }

    public var noContentSubtitle: String? {
        return "You have no Current or Queued Events"
    }

    public var noContentButtonText: String? {
        return "Create new Event"
    }

    public var noContentImage: UIImage? {
        return AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
    }

    public var rightNavBarButtonItemText: String? {
        return "New Event"
    }

    public var tabBarImageSet: (image: UIImage?, selectedImage: UIImage?)? {
        return (image: AssetManager.shared.image(forKey: .tabBarEvents), selectedImage: AssetManager.shared.image(forKey: .tabBarEventsSelected))
    }

}
