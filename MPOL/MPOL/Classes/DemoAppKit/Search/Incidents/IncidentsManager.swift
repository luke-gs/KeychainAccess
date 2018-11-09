//
//  IncidentsManage.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//
import PublicSafetyKit
/// Manages the list of incidents
final public class IncidentsManager {

    public var incidentBucket: ObjectBucket<Incident> = ObjectBucket<Incident>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    public var displayableBucket: ObjectBucket<IncidentListDisplayable> = ObjectBucket<IncidentListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    private(set) public var incidentBuilders = [IncidentType: IncidentBuilding]()

    public init() { }

    public func create(incidentType: IncidentType, in event: Event) -> Incident? {
        guard let incidentBuilder = incidentBuilders[incidentType] else { return nil }

        let incidentDisplayableTuple = incidentBuilder.createIncident(for: incidentType, in: event)
        let incident = incidentDisplayableTuple.incident
        let displayable = incidentDisplayableTuple.displayable

        incident.displayable = displayable

        displayableBucket.add(displayable)
        incidentBucket.add(incident)

        return incident
    }

    //add

    public func add(_ builder: IncidentBuilding, for type: IncidentType) {
        incidentBuilders[type] = builder
    }

    public func add(incident: Incident) {
        incidentBucket.add(incident)
        displayableBucket.add(incident.displayable)
    }

    //remove
    public func remove(incident: Incident) {
        incidentBucket.remove(incident)
    }

    public func remove(for id: String) {
        guard let incident = incident(for: id), let displayable = incident.displayable else { return }
        incidentBucket.remove(incident)
        displayableBucket.remove(displayable)
    }

    //utility
    public func incident(for id: String) -> Incident? {
        if let incident = incidentBucket.objects?.first(where: {$0.id == id}) {
            return incident
        }
        return nil
    }
}
