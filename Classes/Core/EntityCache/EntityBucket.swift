//
//  EntityBucket.swift
//  MPOLKit
//
//  Created by KGWH78 on 21/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


public class EntityBucket {

    public static let didUpdateNotificationName = Notification.Name(rawValue: "EntityBucketDidUpdateNotification")
    public static let addedEntitiesKey: String = "EntityBucketAddedEntitiesKey"
    public static let removedEntitiesKey: String = "EntityBucketRemovedEntitiesKey"

    public let entityManager: EntityManager

    public let limit: Int

    public var entities: [MPOLKitEntity] {
        return entitiesSnapshots.flatMap({ return $0.entity })
    }

    private var entitiesSnapshots: [EntitySnapshot] = []

    /// Initialize an entity bucket.
    ///
    /// - Parameters:
    ///   - limit: The maximum of entities that this bucket can hold. 0 means no limit.
    ///   - entityManager: The entity manager to keep all entities up to date.
    public init(limit: Int = 0, entityManager: EntityManager = EntityManager.default) {
        self.limit = limit
        self.entityManager = entityManager
    }

    /// Adds an entity to this bucket.
    ///
    /// - Parameter entity: The entity.
    public func add(_ entity: MPOLKitEntity) {
        add([entity])
    }

    /// Adds a collection of entities to this bucket.
    ///
    /// - Parameter entities: A collection of entities.
    public func add(_ entities: [MPOLKitEntity]) {
        entities.forEach { entity in
            if entitiesSnapshots.index(where: { $0.entity.isEssentiallyTheSameAs(otherEntity: entity) }) == nil {
                let entitySnapshot = EntitySnapshot(initialEntity: entity, entityManager: entityManager)
                entitySnapshot.delegate = self
                entitiesSnapshots.append(entitySnapshot)
            }
        }

        // Trim entities to fit the limit
        var removedEntities: [MPOLKitEntity]?
        if limit > 0 && entitiesSnapshots.count > limit {
            let range = 0..<(entitiesSnapshots.count - limit)
            removedEntities = entitiesSnapshots[range].flatMap({ return $0.entity })
            entitiesSnapshots.removeSubrange(range)
        }
        
        // Check for removed entities
        let addedEntities: [MPOLKitEntity]
        if let removedEntities = removedEntities {
            addedEntities = entities.filter { !removedEntities.contains($0) }
        } else {
            addedEntities = entities
        }
        
        var userInfo = [EntityBucket.addedEntitiesKey: addedEntities]
        userInfo[EntityBucket.removedEntitiesKey] = removedEntities
        
        NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName, object: self, userInfo: userInfo)
    }

    /// Removes an entity ffrom the bucket.
    ///
    /// - Parameter entity: The entity to remove.
    public func remove(_ entity: MPOLKitEntity) {
        if let index = entitiesSnapshots.index(where: { $0.entity.isEssentiallyTheSameAs(otherEntity: entity) }) {
            let entity = entitiesSnapshots.remove(at: index)
            NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName,
                                            object: self,
                                            userInfo: [EntityBucket.removedEntitiesKey: [entity]])
        }
    }

    /// Removes all entities from the bucket.
    public func removeAll() {
        let entities = entitiesSnapshots.map({ $0.entity })
        entitiesSnapshots.removeAll()
        NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName,
                                        object: self,
                                        userInfo: [EntityBucket.removedEntitiesKey: entities])
    }


    /// Checks if the bucket contains this entity.
    ///
    /// - Parameter entity: The entity to check.
    /// - Returns: True if it is in the bucket. False otherwise.
    public func contains(_ entity: MPOLKitEntity) -> Bool {
        return entitiesSnapshots.contains(where: { $0.entity.isEssentiallyTheSameAs(otherEntity: entity) })
    }

    public func entities<T>(for entityType: T.Type) -> [T] where T: MPOLKitEntity {
        return entitiesSnapshots.flatMap({ $0.entity as? T })
    }

}

extension EntityBucket: EntitySnapshotDelegate {

    public func entitySnapshotDidChange(_ entitySnapshot: EntitySnapshot) {
        NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName, object: self, userInfo: [EntityBucket.addedEntitiesKey: [entitySnapshot.entity]])
    }

}
