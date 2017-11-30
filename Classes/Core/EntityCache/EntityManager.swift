//
//  EntityManager.swift
//  MPOLKit
//
//  Created by KGWH78 on 27/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

extension MPOLKitEntity {

    func canAssumeToBeTheSameAs(otherEntity: MPOLKitEntity) -> Bool {
        return type(of: self) == type(of: otherEntity) && id == otherEntity.id
    }

}


public protocol EntitySnapshotable: class {

    func handleEntityChanged(updatedEntity: MPOLKitEntity)

}

public class EntityManager {

    public static let current = EntityManager()

    public private(set) var snapshots: [EntitySnapshotable] = []

    public private(set) var entities: [MPOLKitEntity] = []

    public init() { }

    // MARK: - Registering

    public func registerSnapshot(_ snapshot: EntitySnapshotable) {
        if !snapshots.contains(where: { $0 === snapshot }) {
            snapshots.append(snapshot)
        }
    }

    public func deregisterSnapshot(_ snapshot: EntitySnapshotable) {
        if let index = snapshots.index(where: { $0 === snapshot }) {
            snapshots.remove(at: index)
        }
    }

    // MARK: - Entity management

    public func addEntity(_ entity: MPOLKitEntity) {
        if let index = entities.index(where: { $0.canAssumeToBeTheSameAs(otherEntity: entity) }) {
            entities.remove(at: index)
        }

        entities.append(entity)
        notifySnapshots(with: entity)
    }

    // MARK: - Fetching

    public func fetch(_ existingEntity: MPOLKitEntity) -> Promise<MPOLKitEntity?> {
        if let cachedEntity = entities.first(where: {
            $0.canAssumeToBeTheSameAs(otherEntity: existingEntity)
        }), cachedEntity !== existingEntity {
            return Promise(value: cachedEntity)
        }

        return Promise(value: nil)
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

public class EntitySnapshot: EntitySnapshotable {

    public private(set) var entity: MPOLKitEntity

    public weak var delegate: EntitySnapshotDelegate?

    public private(set) weak var entityManager: EntityManager?

    public init(initialEntity: MPOLKitEntity, entityManager: EntityManager = EntityManager.current) {
        self.entity = initialEntity
        self.entityManager = entityManager
        entityManager.registerSnapshot(self)
    }

    deinit {
        entityManager?.deregisterSnapshot(self)
    }

    public func handleEntityChanged(updatedEntity: MPOLKitEntity) {
        guard entity !== updatedEntity else { return }

        if entity.canAssumeToBeTheSameAs(otherEntity: updatedEntity) {
            entity = updatedEntity
            delegate?.entitySnapshotDidChange(self)
        }
    }

}
