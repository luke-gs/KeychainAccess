//
//  RelationshipManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final public class RelationshipManager<Base: Equatable, Related: Equatable> {
    private(set) public var relationships = [Relationship<Base, Related>]()

    // MARK: Add

    public func add(_ relationship: Relationship<Base, Related>) {
        relationships.append(relationship)
    }

    public func add(_ reason: String, toRelationship relationship: Relationship<Base, Related>) {
        relationships.first(where: {$0 == relationship})?.reasons.append(reason)
    }

    // MARK: Remove
    
    public func remove(_ relationship: Relationship<Base, Related>) {
        relationships = relationships.filter({$0 != relationship})
    }

    public func remove(_ relationships: [Relationship<Base, Related>]) {
        relationships.forEach{remove($0)}
    }

    // MARK: Update

    public func update(_ reasons: [String], in relationship: Relationship<Base, Related>) {
        guard let relationship = relationships.first(where: { $0 == relationship }) else { return }
        relationship.reasons = reasons
    }

    // MARK: Get

    public func relationship(between baseObject: Base, and relatedObject: Related) -> Relationship<Base, Related>? {
        return relationships.filter { $0.baseObject == baseObject && $0.relatedObject == relatedObject }.first
    }

    public func relationships(for object: Any, and objectType: Any.Type) -> [Relationship<Base, Related>] {
        guard (object is Base || object is Related) else { return [] }
        guard (objectType is Base.Type || objectType is Related.Type) else { return [] }

        return relationships.filter { $0.baseObject == (object as? Base) || $0.relatedObject == (object as? Related) }
    }
}

extension RelationshipManager where Base == Related {

    // MARK: Get

    public func relationships(for object: Base)
        -> (baseObjectRelationships: [Relationship<Base, Related>], relatedObjectRelationships: [Relationship<Base, Related>])
    {
        let base = relationships.filter{$0.baseObject == object}
        let related = relationships.filter{$0.relatedObject == object}
        return (baseObjectRelationships: base, relatedObjectRelationships: related)
    }
}
