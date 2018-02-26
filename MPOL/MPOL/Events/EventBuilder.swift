//
//  EventBuilder.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class EventBuilder: EventBuilding {

    public func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable) {
        let event = Event()

        // Add reports here
        event.add(report: DefaultDateTimeReport(event: event))
        event.add(report: DefaultLocationReport(event: event))
        event.add(report: OfficerListReport(event: event))
        event.add(report: IncidentListReport(event: event))
        event.add(report: DefaultNotesPhotosReport(event: event))

        let displayable = EventListDisplayable(title: "No incident selected",
                                               subtitle: "",
                                               accessoryTitle: "",
                                               accessorySubtitle: "",
                                               icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.event))
        displayable.eventId = event.id
        return (event: event, displayable: displayable)
    }

    public init() { }
}
