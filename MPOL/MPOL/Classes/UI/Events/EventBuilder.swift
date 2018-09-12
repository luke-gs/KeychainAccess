//
//  EventBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

public class EventBuilder: EventBuilding {

    public func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable) {
        let event = Event()

        // Add reports here
        event.add(report: DefaultDateTimeReport(event: event))
        event.add(report: DefaultLocationReport(event: event))
        event.add(report: OfficerListReport(event: event))
        event.add(report: IncidentListReport(event: event))
        event.add(report: EventEntitiesListReport(event: event))
        event.add(report: DefaultNotesMediaReport(event: event))

        let displayable = EventListDisplayable(title: "No Incident Selected",
                                               subtitle: "",
                                               accessoryTitle: "",
                                               accessorySubtitle: "",
                                               icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.event))
        displayable.eventId = event.id
        return (event: event, displayable: displayable)
    }

    public init() {}
}
