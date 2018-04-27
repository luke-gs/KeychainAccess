//
//  EventsListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import PromiseKit

public class EventsListViewModel {

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
        incidentsManager.add(TrafficInfringementIncidentBuilder(), for: .trafficInfringement)
        incidentsManager.add(StreetCheckIncidentBuilder(), for: .interceptReport)

        if let incidentType = incidentType {
            let _ = incidentsManager.create(incidentType: incidentType, in: event)
        }

        screenBuilder.incidentsManager = incidentsManager

        return EventsDetailViewModel(event: event, builder: screenBuilder)
    }

    public func loadingBuilder() -> LoadingViewBuilder<Void> {
        let builder = LoadingViewBuilder<Void>()
        builder.title = "Submitting event"
        builder.promise = firstly { () -> Promise<Void> in
            // TODO: Create network request, get content data and status data
            print("Submitted")
            return after(seconds: 10).asVoid()
        }
        return builder
    }
}

