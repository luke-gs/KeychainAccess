//
//  Reportable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// A convenience for objects that will want to conform to both
/// an eventReportable as well as incidentReportable
public protocol Reportable: IncidentReportable, EventReportable { }

/// Conforming to this protocol ensures that you have a weak reference
/// to the event object
public protocol EventReportable: NSSecureCoding, Evaluatable {

    /// A reference to the event object
    var weakEvent: Weak<Event> { get }
}

extension EventReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the event
    public var event: Event? {
        return weakEvent.object
    }
}

public protocol IncidentReportable: NSSecureCoding, Evaluatable {
    /// A weak reference to the incident object
    var weakIncident: Weak<Incident> { get }
}

extension IncidentReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the incident
    public var incident: Incident? {
        return weakIncident.object
    }
}

public protocol ActionReportable: IncidentReportable {

    /// A weak reference to the additional action object
    /// Make sure this is weak in implementation as well
    var weakAdditionalAction: Weak<AdditionalAction> { get }
}

extension ActionReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the incident
    public var additionalAction: AdditionalAction? {
        return weakAdditionalAction.object
    }
}
