//
//  EventsListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import PromiseKit

public class EventsListViewModel {

    public var title: String
    public var eventsManager: EventsManager
    public var incidentType: IncidentType?

    public var eventsList: [EventListDisplayable]? {
        return eventsManager.displayables
    }

    public var badgeCountString: String? {
        let count = eventsManager.events.count
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
        return eventsManager.event(for: displayable.id)
    }

    func subtitle(for displayable: EventListDisplayable) -> String {
        let eval = event(for: displayable)?.evaluator.isComplete ?? false
        return eval ? "READY TO SUBMIT" : "IN PROGRESS"
    }

    func image(for displayable: EventListDisplayable) -> UIImage {
        let eval = event(for: displayable)?.evaluator.isComplete ?? false
        guard let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.event)?
            .withCircleBackground(tintColor: .black,
                                  circleColor: eval ? .midGreen : .disabledGray,
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
            _ = incidentsManager.create(incidentType: incidentType, in: event)
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
