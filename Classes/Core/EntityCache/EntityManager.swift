//
//  EntityManager.swift
//  MPOLKit
//
//  Created by KGWH78 on 27/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


/// Implement this protocol to handle any changes to the entity
public protocol EntitySnapshotable: class {

    func handleEntityChanged(updatedEntity: MPOLKitEntity)

}


/// This manages snapshots and entities and ensuring that the snapshots are notified when an entity is added.
public class EntityManager {

    public enum EntityManagerError: Error {
        case EntityNotFound
    }

    public static let `default` = EntityManager()

    public private(set) var snapshots: [EntitySnapshotable] = []

    public private(set) var entities: [MPOLKitEntity] = []

    public init() { }

    // MARK: - Registering


    /// Registers a snapshot.
    ///
    /// - Parameter snapshot: A snapshot.
    public func registerSnapshot(_ snapshot: EntitySnapshotable) {
        if !snapshots.contains(where: { $0 === snapshot }) {
            snapshots.append(snapshot)
        }
    }


    /// Deregister a snapshot
    ///
    /// - Parameter snapshot: A snapshot.
    public func deregisterSnapshot(_ snapshot: EntitySnapshotable) {
        if let index = snapshots.index(where: { $0 === snapshot }) {
            snapshots.remove(at: index)
        }
    }

    // MARK: - Entity management

    /// Adds an entity to be managed. If exists, this will replace instead.
    /// All snapshots will also be notified of this change.
    ///
    /// - Parameter entity: The entity.
    public func addEntity(_ entity: MPOLKitEntity) {
        if let index = entities.index(where: { $0.isEssentiallyTheSameAs(otherEntity: entity) }) {
            entities.remove(at: index)
        }

        entities.append(entity)
        notifySnapshots(with: entity)
    }

    // MARK: - Fetching

    /// Fetches for an updated entity from the list.
    ///
    /// - Parameter existingEntity: The entity to fetch.
    /// - Returns: A Promise.
    public func fetch(_ existingEntity: MPOLKitEntity) -> Promise<MPOLKitEntity> {
        if let cachedEntity = entities.first(where: {
            $0.isEssentiallyTheSameAs(otherEntity: existingEntity)
        }), cachedEntity !== existingEntity {
            return Promise(value: cachedEntity)
        }

        return Promise(error: EntityManagerError.EntityNotFound)
    }

    // MARK: - Private

    private func notifySnapshots(with entity: MPOLKitEntity) {
        snapshots.forEach {
            $0.handleEntityChanged(updatedEntity: entity)
        }
    }

}

public protocol EntitySnapshotDelegate: class {

    func entitySnapshotDidChange(_ entitySnapshot: EntitySnapshot)

}

public enum EntitySnapshotError: LocalizedError {
    /// This is thrown when the entityManager of this snapshot is no longer valid.
    case InvalidManager
    
    public var errorDescription: String? {
        switch self {
        case .InvalidManager:
            return "Invalid Manager. Manager may have been deallocated."
        }
    }
}

/// Creates a snapshot of an entity. This entity will be automatically updated when an updated version of the same
/// entity is added to the entity manager.
public class EntitySnapshot: EntitySnapshotable {

    /// The snapshot of entity.
    public private(set) var entity: MPOLKitEntity

    /// Delegate to listen entity changes.
    public weak var delegate: EntitySnapshotDelegate?

    /// The EntityManager to be notified from.
    public private(set) weak var entityManager: EntityManager?


    /// Initialise an EntitySnapshot.
    ///
    /// - Parameters:
    ///   - initialEntity: Initial entity.
    ///   - entityManager: EntityManager to register this snapshot to.
    public init(initialEntity: MPOLKitEntity, entityManager: EntityManager = EntityManager.default) {
        self.entity = initialEntity
        self.entityManager = entityManager
        entityManager.registerSnapshot(self)
    }


    /// Perform a fetch from the entity manager to keep this entity up to date.
    ///
    /// - Returns: A promise.
    public func fetch() -> Promise<MPOLKitEntity> {
        guard let entityManager = entityManager else {
            return Promise(error: EntitySnapshotError.InvalidManager)
        }

        return entityManager.fetch(entity).then { [weak self] (entity) -> MPOLKitEntity in
            self?.entity = entity
            return entity
        }
    }

    deinit {
        entityManager?.deregisterSnapshot(self)
    }

    /// Notified by the entity manager.
    ///
    /// - Parameter updatedEntity: A new entity that was recently added.
    public func handleEntityChanged(updatedEntity: MPOLKitEntity) {
        guard entity !== updatedEntity else { return }

        if entity.isEssentiallyTheSameAs(otherEntity: updatedEntity) {
            entity = updatedEntity
            delegate?.entitySnapshotDidChange(self)
        }
    }

}
