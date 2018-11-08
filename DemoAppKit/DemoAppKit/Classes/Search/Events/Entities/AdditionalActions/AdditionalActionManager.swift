//
//  AdditionalActionManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final public class AdditionalActionManager {
    private weak var incident: Incident!
    private let additionalActionRelationshipManager = RelationshipManager<MPOLKitEntity, AdditionalAction>()

    public init(incident: Incident) {
        self.incident = incident
    }

    public var allValid: Bool {
        return incident.actions.reduce(true, { (_, action) -> Bool in
            return action.evaluator.isComplete
        })
    }

    public func actionRelationships(for entity: MPOLKitEntity) -> [Relationship<MPOLKitEntity, AdditionalAction>] {
        return additionalActionRelationshipManager.relationships(for: entity, and: AdditionalAction.self)
    }

    public func relationship(between entity: MPOLKitEntity, and action: AdditionalAction) -> Relationship<MPOLKitEntity, AdditionalAction>? {
        return additionalActionRelationshipManager.relationship(between: entity, and: action)
    }

    public func add(_ action: AdditionalAction, to entity: MPOLKitEntity) {
        incident.actions.append(action)

        let actionRelationship = Relationship(baseObject: entity, relatedObject: action)
        additionalActionRelationshipManager.add(actionRelationship)
    }

    public func remove(_ action: AdditionalAction, from entity: MPOLKitEntity) {
        // Remove the relationship between the action and the entity
        if let actionRelationships = additionalActionRelationshipManager.relationship(between: entity, and: action) {
            additionalActionRelationshipManager.remove(actionRelationships)
        }
        //remove the action
        incident.actions = incident.actions.filter { $0 != action }
    }
}
