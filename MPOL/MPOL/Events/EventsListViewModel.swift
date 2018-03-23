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
    public var eventsManager: EventsManager
    public var incidentType: IncidentType?

    public var eventsList: [EventListDisplayable]? {
        return eventsManager.displayableBucket.objects
    }

    public required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
        self.title = "Events"
    }
    
    public func event(for displayable: EventListDisplayable) -> Event? {
        return eventsManager.event(for: displayable.eventId)
    }
    
    public func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        let screenBuilder = EventScreenBuilder()
        let incidentsManager = IncidentsManager()

        // Add IncidentBuilders here
        incidentsManager.add(InfringementIncidentBuilder(), for: .infringementNotice)
        incidentsManager.add(StreetCheckIncidentBuilder(), for: .streetCheck)

        if let incidentType = incidentType {
            let _ = incidentsManager.create(incidentType: incidentType, in: event)
        }

        screenBuilder.incidentsManager = incidentsManager

        return EventsDetailViewModel(event: event, builder: screenBuilder)
    }
}

