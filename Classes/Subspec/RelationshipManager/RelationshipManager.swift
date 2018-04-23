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

    public func relationshipsFor(entity: MPOLKitEntity) -> (baseEntity: [Relationship]?, toEntity: [Relationship]?) {
        let base = relationships.filter{$0.baseEntity == entity}
        let to = relationships.filter{$0.toEntity == entity}
        return (baseEntity: base, toEntity: to)
    }
}

public class Relationship: Equatable {
    public var baseEntity: MPOLKitEntity
    public var toEntity: MPOLKitEntity
    public var reasons: [String] = [String]()

    init(baseEntity: MPOLKitEntity, toEntity: MPOLKitEntity, reasons: [String] = []) {
        self.baseEntity = baseEntity
        self.toEntity = toEntity
        self.reasons = reasons
    }

    //Equality
    public static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.baseEntity == rhs.baseEntity
            && lhs.toEntity == lhs.toEntity
            && lhs.reasons == rhs.reasons
    }

}
