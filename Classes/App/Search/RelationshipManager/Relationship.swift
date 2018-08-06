//
//  Relationship.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A relationship object used to relate two Relatables
public class Relationship<Base: Equatable, Related: Equatable>: Equatable {

    /// The base object of the relationship
    public var baseObject: Base

    /// The object that is related to the baseObject
    public var relatedObject: Related

    /// The reasons how the objects are related
    public var reasons: [String]?

    /// Create a new relationship between objects
    ///
    /// - Parameters:
    ///   - baseObject: the base object of the relationship
    ///   - relatedObject: the object that is related to the baseObject
    ///   - reasons: the reasons how the objects are related
    public init(baseObject: Base, relatedObject: Related, reasons: [String]? = nil) {
        self.baseObject = baseObject
        self.relatedObject = relatedObject
        self.reasons = reasons
    }

    //Equality
    public static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.baseObject == rhs.baseObject
            && lhs.relatedObject == rhs.relatedObject
    }
}

extension Relationship where Base == Related {

    public func contains(_ object: Base) -> Bool {
        return baseObject == object || relatedObject == object
    }
}
