//
//  EventEntityManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final public class EventEntityManager {
    private weak var event: Event!
    private let entityBucket = EntityBucket()
    private let incidentRelationshipManager = RelationshipManager<MPOLKitEntity, Incident>()
    private let entityRelationshipManager = RelationshipManager<MPOLKitEntity, MPOLKitEntity>()

    public weak var delegate: EntityBucketDelegate? {
        didSet {
            entityBucket.delegate = delegate
        }
    }

    public init(event: Event) {
        self.event = event
    }

    // MARK: Incident -> Entity

    public var incidentRelationships: [Relationship<MPOLKitEntity, Incident>] {
        return incidentRelationshipManager.relationships
    }

    public func relationships(for incident: Incident) -> [Relationship<MPOLKitEntity, Incident>] {
        return incidentRelationshipManager.relationships(for: incident, and: MPOLKitEntity.self)
    }

    public func relationship(between entity: MPOLKitEntity, and incident: Incident) -> Relationship<MPOLKitEntity, Incident>? {
        return incidentRelationshipManager.relationship(between: entity, and: incident)
    }

    public func add(_ entity: MPOLKitEntity, to incident: Incident, with involvements: [String]?) {
        entityBucket.add(entity)
        event?.entities[entity.uuid] = entity

        DispatchQueue.main.async {
            if let data = try? JSONEncoder().encode(self.event!) {
                if let copy = try? JSONDecoder().decode(Event.self, from: data) {
                    print(copy)
                }
            }
        }

        let incidentRelationship = Relationship(baseObject: entity, relatedObject: incident, reasons: involvements)
        incidentRelationshipManager.add(incidentRelationship)
    }

    public func update(_ reasons: [String]?, between entity: MPOLKitEntity, and incident: Incident) {
        if let incidentRelationship = incidentRelationshipManager.relationship(between: entity, and: incident) {
            incidentRelationshipManager.update(reasons, in: incidentRelationship)
        }
    }

    public func remove(_ entity: MPOLKitEntity, from incident: Incident) {

        // Remove the relationship between the entity and the incident
        if let incidentRelationships = incidentRelationshipManager.relationship(between: entity, and: incident) {
            incidentRelationshipManager.remove(incidentRelationships)
        }
        // If the are no more incident->entity relationships, remove the entity and all its relationships
        if incidentRelationshipManager.relationships(for: entity, and: Incident.self).isEmpty {
            entityBucket.remove(entity)
            event?.entities[entity.uuid] = nil
            removeAllRelationships(for: entity)
        }
    }

    public func removeAllRelationships(for incident: Incident) {
        let relationships = incidentRelationshipManager.relationships(for: incident, and: MPOLKitEntity.self)
        relationships.forEach { remove($0.baseObject, from: $0.relatedObject) }
    }

    // MARK: Entity -> Entity

    public var entityRelationships: [Relationship<MPOLKitEntity, MPOLKitEntity>] {
        return entityRelationshipManager.relationships
    }

    public func relationship(between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity) -> Relationship<MPOLKitEntity, MPOLKitEntity>? {
        return entityRelationshipManager.relationship(between: entity, and: relatedEntity)
    }

    public func addRelationship(between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity, with reasons: [String]) {
        let entityRelationship = Relationship(baseObject: entity, relatedObject: relatedEntity, reasons: reasons)
        entityRelationshipManager.add(entityRelationship)
    }

    public func update(_ reasons: [String], between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity) {
        if let entityRelationship = entityRelationshipManager.relationship(between: entity, and: relatedEntity) {
            entityRelationshipManager.update(reasons, in: entityRelationship)
        }
    }

    public func removeRelationships(between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity) {
        if let entityRelationship = entityRelationshipManager.relationship(between: entity, and: relatedEntity) {
            entityRelationshipManager.remove(entityRelationship)
        }
    }

    public func removeRelationship(_ relationship: Relationship<MPOLKitEntity, MPOLKitEntity>) {
        entityRelationshipManager.remove(relationship)
    }

    public func removeAllRelationships(for entity: MPOLKitEntity) {
        entityRelationshipManager.relationships(for: entity).baseObjectRelationships.forEach {removeRelationship($0)}
        entityRelationshipManager.relationships(for: entity).relatedObjectRelationships.forEach {removeRelationship($0)}
    }

}
