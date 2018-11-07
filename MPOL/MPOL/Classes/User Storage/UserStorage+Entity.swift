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
    ///     - notification: The name for notifying changes to notification center
    /// - Throws: error occurs when encoding & saving the Entity
    public func addEntity<T: MPOLKitEntity>(object: T, key: String, notification name: Notification.Name? = nil) throws {
        var result: [T]
        if let entities = self.retrieve(key: key) as [T]? {
            result = entities
            result.append(object)
        } else {
            result = [object]
        }
        try self.addWrapped(objects: result, key: key, flag: UserStorageFlag.session)
        if let notificationName = name {
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    /// Get Entities with Key
    /// Entities must subclass MPOLKitEntity
    /// - Parameter key: where Entities stores
    /// - Returns: return an array of Entities
    public func getEntities<T: MPOLKitEntity>(key: String) -> [T]? {
        return self.retrieveUnwrapped(key: key) ?? nil
    }

}
public extension NSNotification.Name {
    public static let CreatedEntitiesDidUpdate = NSNotification.Name(rawValue: "CreatedEntitiesDidUpdate")
}
