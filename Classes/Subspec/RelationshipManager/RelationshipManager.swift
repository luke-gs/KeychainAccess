//
//  RelationshipManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final public class RelationshipManager {
    private(set) public var relationships = [Relationship]()

    public func add(_ relationship: Relationship) {
        relationships.append(relationship)
    }

    public func addReason(_ reason: String, to relationship: Relationship) {
        relationships.first(where: {$0 == relationship})?.reasons.append(reason)
    }
    
    public func relationshipsFor(_ entity: MPOLKitEntity)
        -> (baseEntityRelationships: [Relationship]?, relatedEntityRelationships: [Relationship]?)
    {
        let base = relationships.filter{$0.baseEntity == entity}
        let related = relationships.filter{$0.relatedEntity == entity}
        return (baseEntityRelationships: base, relatedEntityRelationships: related)
    }
}
