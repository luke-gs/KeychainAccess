//
//  EventsManager.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of incidents
///
/// Can be used as a singleton as well as an instance if necessary.
final public class IncidentsManager {

    /// The shared Eventsmanager singleton
    public static var shared: IncidentsManager = {
        let eventsManager = IncidentsManager()
        eventsManager.incidentBucket = ObjectBucket<Incident>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        eventsManager.displayableBucket = ObjectBucket<IncidentListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        return eventsManager
    }()

    public var incidentBucket: ObjectBucket<Incident>?
    public var displayableBucket: ObjectBucket<IncidentListDisplayable>?
    public var incidentBuilder: IncidentBuilding?

    public convenience init(incidentBucket: ObjectBucket<Incident>,
                            displayableBucket: ObjectBucket<IncidentListDisplayable>,
                            incidentBuilder: IncidentBuilding)
    {
        self.init()
        self.incidentBucket = incidentBucket
        self.displayableBucket = displayableBucket
        self.incidentBuilder = incidentBuilder
    }

    public init() { }

    public func create(incidentType: IncidentType) -> Incident? {
        guard let incident = incidentBuilder?.createIncident(for: incidentType) else { return nil }
        displayableBucket?.add(incident.displayable)
        incidentBucket?.add(incident.incident)

        return incident.incident
    }

    //add
    public func add(incident: Incident) {
        incidentBucket?.add(incident)
    }

    //remove
    public func remove(incident: Incident) {
        incidentBucket?.remove(incident)
    }

    public func remove(for id: UUID) {
        guard let incident = incident(for: id) else {
            return
        }
        incidentBucket?.remove(incident)
        if let displayable = displayableBucket?.objects?.first(where: {$0.incidentId == id}) {
            displayableBucket?.remove(displayable)
        }
    }

    //utility
    public func incident(for id: UUID) -> Incident? {
        if let event = incidentBucket?.objects?.first(where: {$0.id == id}) {
            return event
        }
        return nil
    }
}


