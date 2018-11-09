//
//  EventBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

public class EventBuilder: EventBuilding {

    public func createEvent(for type: EventType) -> Event {
        let event = Event()

        // Add reports here
        event.add(report: DefaultDateTimeReport(event: event))
        event.add(report: DefaultLocationReport(event: event))
        event.add(report: OfficerListReport(event: event))
        event.add(report: IncidentListReport(event: event))
        event.add(report: EventEntitiesListReport(event: event))
        event.add(report: DefaultNotesMediaReport(event: event))

        return event
    }

    public func displayable(for event: Event) -> EventListDisplayable {
        return EventListDisplayable(
            id: event.id,
            title: event.title,
            subtitle: "IN PROGRESS", // ??
            accessoryTitle: "",
            accessorySubtitle: "",
            iconKey: AssetManager.ImageKey.event)
    }

    public init() {}
}
