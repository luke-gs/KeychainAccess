//
//  IncidentsManage.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 23/1/18.
//

/// Manages the list of incidents
final public class IncidentsManager {

    public var incidentBucket: ObjectBucket<Incident> = ObjectBucket<Incident>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    public var displayableBucket: ObjectBucket<IncidentListDisplayable> = ObjectBucket<IncidentListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    private(set) public var incidentBuilders = [IncidentType: IncidentBuilding]()

    public init() { }

    public func create(incidentType: IncidentType, in event: Event) -> (incident: Incident, displayable: IncidentListDisplayable)? {
        guard let incidentBuilder = incidentBuilders[incidentType] else { return nil }

        let incidentDisplayableTuple = incidentBuilder.createIncident(for: incidentType, in: event)
        incidentDisplayableTuple.incident.displayable = incidentDisplayableTuple.displayable

        displayableBucket.add(incidentDisplayableTuple.displayable)
        incidentBucket.add(incidentDisplayableTuple.incident)

        return incidentDisplayableTuple
    }

    //add

    public func add(_ builder: IncidentBuilding, for type: IncidentType) {
        incidentBuilders[type] = builder
    }

    public func add(incident: Incident) {
        incidentBucket.add(incident)
    }

    //remove
    public func remove(incident: Incident) {
        incidentBucket.remove(incident)
    }

    public func remove(for id: UUID) {
        guard let incident = incident(for: id), let displayable = incident.displayable else { return }
        incidentBucket.remove(incident)
        displayableBucket.remove(displayable)
    }

    //utility
    public func incident(for id: UUID) -> Incident? {
        if let incident = incidentBucket.objects?.first(where: {$0.id == id}) {
            return incident
        }
        return nil
    }
}
