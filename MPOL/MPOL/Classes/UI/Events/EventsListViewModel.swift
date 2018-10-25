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

    /// Returns the event's date of creation, may be nil.
    public func eventCreationString(for displayable: EventListDisplayable) -> String? {
        guard let event = event(for: displayable) else { return nil }
        return event.creationDateString
    }

    /// Return's the event's location, may be nil.
    public func eventLocationString(for displayable: EventListDisplayable) -> String? {
        if let event = event(for: displayable) {
            if let locationReport = event.reports.first(where: {$0 is DefaultLocationReport}) {
                return ((locationReport as! DefaultLocationReport).eventLocation?.addressString ?? "Location Unknown")
            }
        }
        return nil
    }

    func subtitle(for displayable: EventListDisplayable) -> String? {
        let eventCreationString = self.eventCreationString(for: displayable)
        let eventLocationString = self.eventLocationString(for: displayable)
        var values = [eventCreationString, eventLocationString].compactMap { $0 }
        if values.count > 1 {
            values.insert("\n", at: 1)
        }
        return values.joined()
    }

    func image(for displayable: EventListDisplayable, eventStatus: EventStatus) -> UIImage {
        let isDark = ThemeManager.shared.currentInterfaceStyle == .dark

        var image: UIImage?

        switch eventStatus {
        case .draft:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .black : .white, circleColor: isDark ? .white : .black, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        case .queued:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .white : .black, circleColor: isDark ? .darkGray : .disabledGray, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        }

        if let image = image {
            return image
        }

        fatalError("Image for event could not be generated")
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

public enum EventStatus {
    case draft
    case queued
}
