//
//  IncidentsManage.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//
import PublicSafetyKit

/// Manages the list of incidents within an event
final public class IncidentsManager {

    private weak var event: Event?

    private(set) public var incidentBuilders = [IncidentType: IncidentBuilding]()

    public init(event: Event) {
        self.event = event
    }

    public var incidents: [Incident] {
        return event?.incidentListReport?.incidents ?? []
    }

    public func create(incidentType: IncidentType, in event: Event) -> Incident? {
        guard let incidentBuilder = incidentBuilders[incidentType] else { return nil }
        return incidentBuilder.createIncident(for: incidentType, in: event)
    }

    /// Return the current incidents as displayables
    public var displayables: [IncidentListDisplayable] {
        return incidents.compactMap { incident in
            guard let incidentBuilder = incidentBuilders[incident.incidentType] else { return nil }
            return incidentBuilder.displayable(for: incident)
        }
    }

    /// Add an incident builder for an incident type
    public func add(_ builder: IncidentBuilding, for type: IncidentType) {
        incidentBuilders[type] = builder
    }

    public func add(incident: Incident) {
        event?.incidentListReport?.incidents.append(incident)
    }

    /// Fetch an incident by id
    public func incident(for id: String) -> Incident? {
        if let incident = incidents.first(where: {$0.id == id}) {
            return incident
        }
        return nil
    }
}
