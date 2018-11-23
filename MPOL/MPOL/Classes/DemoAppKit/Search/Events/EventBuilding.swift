//
//  EventBuilding.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit
import PublicSafetyKit

/// Builder for event
///
/// Used to define what an event should look like for a specific event type
/// in terms of the reports it should have
public protocol EventBuilding {

    /// Create an event, injecting any reports that you need.
    ///
    /// - Parameter eventType: The type of event that is being asked to be created.
    /// - Parameter incidentType: The type of default incident, or nil for none.
    /// - Returns: The new event
    func createEvent(eventType: EventType, incidentType: IncidentType?) -> Event

    /// Create a displayable for an event, to be shown in event list
    ///
    /// - Parameter event: The event
    /// - Returns: The list displayable
    func displayable(for event: Event) -> EventListItemViewModelable

}

/// Screen builder for the event
///
/// Used to provide a viewcontroller for the reportables
///
/// Can be used to provide different view controllers for OOTB reports
/// - ie. DateTimeReport
public protocol EventScreenBuilding {

    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: The array of reports to construct view controllers for
    /// - Returns: An array of viewController constucted for the reports
    func viewControllers(for reportables: [EventReportable]) -> [UIViewController]
}
