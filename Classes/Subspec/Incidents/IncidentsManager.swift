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
    private(set) public var incidentBuilders = [IncidentType: IncidentBuilding]()

    public convenience init(incidentBucket: ObjectBucket<Incident>,
                            displayableBucket: ObjectBucket<IncidentListDisplayable>)
    {
        self.init()
        self.incidentBucket = incidentBucket
        self.displayableBucket = displayableBucket
    }

    private init() { }

    public func create(incidentType: IncidentType, in event: Event) -> (incident: Incident, displayable: IncidentListDisplayable)? {
        guard let incidentBuilder = incidentBuilders[incidentType] else { return nil }

        let incident = incidentBuilder.createIncident(for: incidentType, in: event)
        displayableBucket?.add(incident.displayable)
        incidentBucket?.add(incident.incident)

        return incident
    }

    //add

    public func add(_ builder: IncidentBuilding, for type: IncidentType) {
        incidentBuilders[type] = builder
    }

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
        if let incident = incidentBucket?.objects?.first(where: {$0.id == id}) {
            return incident
        }
        return nil
    }
}
