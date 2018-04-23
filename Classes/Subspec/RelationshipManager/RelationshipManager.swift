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

    public func relationshipsFor(entity: MPOLKitEntity) -> (toEntity: [Relationship]?, fromEntity: [Relationship]?) {
        let to = relationships.filter{$0.toEntity == entity}
        let from = relationships.filter{$0.fromEntity == entity}
        return (toEntity: to, fromEntity: from)
    }
}

public class Relationship: Equatable {
    var fromEntity: MPOLKitEntity
    var toEntity: MPOLKitEntity
    var reasons: [String] = [String]()

    init(fromEntity: MPOLKitEntity, toEntity: MPOLKitEntity, reasons: [String] = []) {
        self.fromEntity = fromEntity
        self.toEntity = toEntity
        self.reasons = reasons
    }

    //Equality
    public static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.fromEntity == rhs.fromEntity
            && lhs.toEntity == lhs.toEntity
            && lhs.reasons == rhs.reasons
    }

}
