//
//  EventsListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit
import PromiseKit

public class EventsListViewModel: EventCardsViewModelable {

    public var title: String
    public var eventsManager: EventsManager
    public var incidentType: IncidentType?

    public var eventsList: [EventListDisplayable]? {
        return eventsManager.displayableBucket.objects
    }

    public var badgeCountString: String? {
        let count = eventsManager.eventBucket.objects?.count ?? 0
        if count > 0 {
            return "\(count)"
        } else {
            return nil
        }
    }

    public required init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
        self.title = "Events"
    }
    
    public func event(for displayable: EventListDisplayable) -> Event? {
        return eventsManager.event(for: displayable.eventId)
    }

    func subtitle(for displayable: EventListDisplayable) -> String? {
        //TODO: Calculate time here
        if let event = event(for: displayable) {
            if let locationReport = event.reports.first(where: {$0 is DefaultLocationReport}) {
                return event.creationDateString + "\n" + ((locationReport as! DefaultLocationReport).eventLocation?.addressString ?? "Location Unknown")
            }
        }

        return nil
    }

    func image(for displayable: EventListDisplayable, isQueued: Bool) -> UIImage {
        let isDark = ThemeManager.shared.currentInterfaceStyle == .dark
        guard let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
            .withCircleBackground(tintColor: isQueued ? (isDark ? .white : .black) : (isDark ? .black : .white),
                                  circleColor: isQueued ? (isDark ? .darkGray : .disabledGray) : (isDark ? .white : .black),
                                  style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false)) else { fatalError() }
        return image
    }
    
    public func detailsViewModel(for event: Event) -> EventDetailViewModelType {
        let screenBuilder = EventScreenBuilder()
        let incidentsManager = IncidentsManager()

        // Add IncidentBuilders here
        incidentsManager.add(TrafficInfringementIncidentBuilder(), for: .trafficInfringement)
        incidentsManager.add(InterceptReportIncidentBuilder(), for: .interceptReport)
        incidentsManager.add(DomesticViolenceIncidentBuilder(), for: .domesticViolence)

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
