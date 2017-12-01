//
//  EntityBucket.swift
//  MPOLKit
//
//  Created by KGWH78 on 21/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


public enum EntityBucketError: Error {
    case notFound
    case duplicate
}


public class EntityBucket {

    public static let didUpdateNotificationName = Notification.Name(rawValue: "EntityCacheDidUpdateNotification")
    public static let addedEntitiesKey: String = "EntityCacheAddedEntitiesKey"
    public static let removedEntitiesKey: String = "EntityCacheRemovedEntitiesKey"

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
        if entitiesSnapshots.index(where: { $0.entity.canAssumeToBeTheSameAs(otherEntity: entity) }) == nil {
            let entitySnapshot = EntitySnapshot(initialEntity: entity, entityManager: entityManager)
            entitySnapshot.delegate = self
            entitiesSnapshots.append(entitySnapshot)

            var userInfo = [EntityBucket.addedEntitiesKey: [entity]]
            userInfo[EntityBucket.removedEntitiesKey] = trimToSize()

            NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName, object: self, userInfo: userInfo)
        }
    }

    /// Adds a collection of entities to this bucket.
    ///
    /// - Parameter entities: A collection of entities.
    public func add(_ entities: [MPOLKitEntity]) {
        entities.forEach { entity in
            if entitiesSnapshots.index(where: { $0.entity.canAssumeToBeTheSameAs(otherEntity: entity) }) == nil {
                let entitySnapshot = EntitySnapshot(initialEntity: entity, entityManager: entityManager)
                entitySnapshot.delegate = self
                entitiesSnapshots.append(entitySnapshot)
            }
        }

        var userInfo = [EntityBucket.addedEntitiesKey: entities]
        userInfo[EntityBucket.removedEntitiesKey] = trimToSize()

        NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName, object: self, userInfo: userInfo)
    }

    /// Removes an entity ffrom the bucket.
    ///
    /// - Parameter entity: The entity to remove.
    public func remove(_ entity: MPOLKitEntity) {
        if let index = entitiesSnapshots.index(where: { $0.entity.canAssumeToBeTheSameAs(otherEntity: entity) }) {
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
        return entitiesSnapshots.contains(where: { $0.entity.canAssumeToBeTheSameAs(otherEntity: entity) })
    }

    public func entities<T>(for entityType: T.Type) -> [T] where T: MPOLKitEntity {
        return entitiesSnapshots.flatMap({ $0.entity as? T })
    }

    // MARK: - Private

    private func trimToSize() -> [MPOLKitEntity]? {
        var entities: [MPOLKitEntity]?
        if limit > 0 && entitiesSnapshots.count > limit {
            let range = 0..<(entitiesSnapshots.count - limit)
            entities = entitiesSnapshots[range].flatMap({ return $0.entity })
            entitiesSnapshots.removeSubrange(range)
        }
        return entities
    }

}

extension EntityBucket: EntitySnapshotDelegate {

    public func entitySnapshotDidChange(_ entitySnapshot: EntitySnapshot) {
        NotificationCenter.default.post(name: EntityBucket.didUpdateNotificationName, object: self, userInfo: [EntityBucket.addedEntitiesKey: [entitySnapshot.entity]])
    }

}


