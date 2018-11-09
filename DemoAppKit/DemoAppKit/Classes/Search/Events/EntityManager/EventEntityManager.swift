//
//  EventEntityManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final public class EventEntityManager {
    private weak var event: Event!
    private let incidentRelationshipManager = RelationshipManager<MPOLKitEntity, Incident>()
    private let entityRelationshipManager = RelationshipManager<MPOLKitEntity, MPOLKitEntity>()

    public weak var delegate: EntityBucketDelegate? {
        didSet {
            event.entityBucket.delegate = delegate
        }
    }

    public init(event: Event) {
        self.event = event
    }

    // MARK: Incident -> Entity

    public var incidentRelationships: [Relationship] {
        return incidentRelationshipManager.relationships
    }

    public func relationships(for incident: Incident) -> [Relationship] {
        return incidentRelationshipManager.relationships(for: incident, and: MPOLKitEntity.self)
    }

    public func relationship(between entity: MPOLKitEntity, and incident: Incident) -> Relationship? {
        return incidentRelationshipManager.relationship(between: entity, and: incident)
    }

    public func add(_ entity: MPOLKitEntity, to incident: Incident, with involvements: [String]?) {
        event?.entityBucket.add(entity)

        incidentRelationshipManager.addRelationship(baseObject: entity, relatedObject: incident, reasons: involvements)
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
            event?.entityBucket.remove(entity)
            removeAllRelationships(for: entity)
        }
    }

    public func removeAllRelationships(for incident: Incident) {
        let relationships = incidentRelationshipManager.relationships(for: incident, and: MPOLKitEntity.self)
        for relationship in relationships {
            if let baseObject = incident.weakEvent.object?.entityBucket.entity(uuid: relationship.baseObjectUuid) {
                remove(baseObject, from: incident)
            }
        }
    }

    // MARK: Entity -> Entity

    public var entityRelationships: [Relationship] {
        return entityRelationshipManager.relationships
    }

    public func relationship(between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity) -> Relationship? {
        return entityRelationshipManager.relationship(between: entity, and: relatedEntity)
    }

    public func addRelationship(between entity: MPOLKitEntity, and relatedEntity: MPOLKitEntity, with reasons: [String]) {
        entityRelationshipManager.addRelationship(baseObject: entity, relatedObject: relatedEntity, reasons: reasons)
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

    public func removeRelationship(_ relationship: Relationship) {
        entityRelationshipManager.remove(relationship)
    }

    public func removeAllRelationships(for entity: MPOLKitEntity) {
        entityRelationshipManager.relationships(for: entity).baseObjectRelationships.forEach {removeRelationship($0)}
        entityRelationshipManager.relationships(for: entity).relatedObjectRelationships.forEach {removeRelationship($0)}
    }

}
