//
//  UserStorage+Entity.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
public extension UserStorage {

    public static let CreatedEntitiesKey = "CreatedEntitiesKey"

    /// Add an Entity to UserStorage with Key.
    /// The new Entity will be appended to an existing array of entities if there are already objects in that Key.
    /// - Parameter
    ///     - object: Any Entity that subclasses MPOLKitEntity
    ///     - key: Where Entity stores. Must be unique
    /// - Throws: error occurs when encoding & saving the Entity
    public func addEntity<T: MPOLKitEntity>(object: T, key: String) throws {
        var result: [T]
        if let entities = self.retrieve(key: key) as [T]? {
            result = entities
            result.append(object)
        } else {
            result = [object]
        }
        try self.addWrapped(objects: result, key: UserStorage.CreatedEntitiesKey, flag: UserStorageFlag.session)
        NotificationCenter.default.post(name: NSNotification.Name.CreatedEntitiesDidUpdate, object: nil)
    }
}
public extension NSNotification.Name {
    public static let CreatedEntitiesDidUpdate = NSNotification.Name(rawValue: "CreatedEntitiesDidUpdate")
}
