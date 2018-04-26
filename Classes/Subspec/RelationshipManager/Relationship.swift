//
//  Relationship.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class Relationship: Equatable {
    public var baseEntity: MPOLKitEntity
    public var relatedEntity: MPOLKitEntity
    public var reasons: [String] = [String]()

    init(baseEntity: MPOLKitEntity, relatedEntity: MPOLKitEntity, reasons: [String] = []) {
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
