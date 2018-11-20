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

        // Use location of event as subtitle
        var subtitle: String?
        if let locationReport = event.reports.compactMap({ $0 as? DefaultLocationReport }).first {
            subtitle = locationReport.eventLocation?.addressString ?? "Location Unknown"
        }

        return EventListDisplayable(
            id: event.id,
            creationDate: event.creationDate,
            title: event.title,
            subtitle: subtitle,
            accessoryTitle: "",
            accessorySubtitle: "",
            iconKey: AssetManager.ImageKey.event)
    }

    public init() {}
}
