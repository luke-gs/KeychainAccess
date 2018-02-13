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
        event.add(report: DefaultNotesPhotosReport(event: event))

        let displayable = EventListDisplayable(title: "Demo",
                                               subtitle: "Sub",
                                               accessoryTitle: "AccessTitle",
                                               accessorySubtitle: "Acces Sub",
                                               icon: AssetManager.shared.image(forKey: AssetManager.ImageKey.advancedSearch))
        return (event: event, displayable: displayable)
    }

    public init() { }
}
