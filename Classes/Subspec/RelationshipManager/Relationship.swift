//
//  Relationship.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit


/// A relationship object used to relate to entities
public class Relationship: Equatable {

    /// The base entity of the relationship
    public var baseEntity: MPOLKitEntity

    /// The entity that is related to the baseEntity
    public var relatedEntity: MPOLKitEntity

    /// The reasons how the entities are related
    public var reasons: [String] = [String]()

    /// Create a new relationship between entities
    ///
    /// - Parameters:
    ///   - baseEntity: the base entity of the relationship
    ///   - relatedEntity: the entity that is related to the baseEntity
    ///   - reasons: the reasons how the entities are related
    public init(baseEntity: MPOLKitEntity, relatedEntity: MPOLKitEntity, reasons: [String] = []) {
        self.baseEntity = baseEntity
        self.relatedEntity = relatedEntity
        self.reasons = reasons
    }

    //Equality
    public static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.baseEntity == rhs.baseEntity
            && lhs.relatedEntity == lhs.relatedEntity
            && lhs.reasons == rhs.reasons
    }

}
