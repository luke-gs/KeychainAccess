//
//  EventsListViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class EventsListViewModel: EventListViewModelType {
    public var title: String

    public var eventsList: [EventListDisplayable]? {
        return eventsManager.displayableBucket?.objects
    }
    public var eventsManager: EventsManager
    
    public required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
        self.title = "Events"
    }
    
    public func event(for displayable: EventListDisplayable) -> Event? {
        return eventsManager.event(for: displayable.eventId)
    }
    
    public func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        return EventsDetailViewModel(event: event, builder: EventScreenBuilder())
    }
}

