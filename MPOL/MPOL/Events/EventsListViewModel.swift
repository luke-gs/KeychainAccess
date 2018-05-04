//
//  EventsListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import PromiseKit
import ClientKit

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

    public func loadingBuilder() -> LoadingViewBuilder<EventSubmissionResponse> {
        let builder = LoadingViewBuilder<EventSubmissionResponse>()
        builder.title = "Submitting event"
        builder.preferredContentSize = CGSize(width: 512, height: 240)

        builder.request = { return APIManager.shared.submitEvent(in: MPOLSource.pscore,
                                                                 with: EventSubmissionRequest()) }
        
        return builder
    }
}

