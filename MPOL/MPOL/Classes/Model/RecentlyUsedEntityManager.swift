//
//  RecentlyUsedEntityManager.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

public class RecentlyUsedEntityManager {

    public static let StandardShelfLife = 30
    public static let shared = RecentlyUsedEntityManager()

    private var entityBucket = EntityBucket()
    private var fetchRequests = [String: (MPOLKitEntity) -> (Promise<Any>)]()

    /// This function uses provided ids and closure to return all associated entities stored both locally and remotley.
    /// Expired local entities will be replaced with their up to date remote copies.
    ///
    /// Returns: A promise of an array of all entities matching the given id's
    ///
    /// Paramaters:
    /// ids - an array of entity ids we want to retrieve
    /// entityFetchRequest - a closure that can retrieve an entity of a specific type using its id
    public func entities(forIds ids: [String], entityTypeRequest: ((String) -> Promise<MPOLKitEntity>)) -> Promise<[MPOLKitEntity]?> {

        return Promise { seal in

            var entitiesToReturn: [MPOLKitEntity] = []
            var entitiesToFectch: [String] = []

            // Sort through all entities we have locally and entities we have to fetch from remote
            ids.forEach { id in
                if let entity = entityBucket.entities.first(where: {$0.id == id}) {
                    entitiesToReturn.append(entity)
                } else {
                    entitiesToFectch.append(id)
                }
            }

            // if any entities are expired add them to the list to fetch
            entitiesToReturn.forEach { entity in
                if let expiry = entity.expiryDate, Date() >= expiry {
                    entitiesToFectch.append(entity.id)
                }
            }

            guard !entitiesToFectch.isEmpty else {
                seal.fulfill(entitiesToReturn)
                return
            }

            let entityRequests = entitiesToFectch.map { id in
                return entityTypeRequest(id)
            }

            when(resolved: entityRequests).done { results in

                results.forEach { result in
                    switch result {
                    case .fulfilled(let remoteEntity):

                        // update expired entities
                        if let entityToUpdate = entitiesToReturn.enumerated().first(where: {$0.element.id == remoteEntity.id}) {
                            entitiesToReturn[entityToUpdate.offset] = entityToUpdate.element
                        } else {

                            // add new entities
                            entitiesToReturn.append(remoteEntity)
                        }

                    case .rejected(let error):
                        print(error)
                    }
                }

                seal.fulfill(entitiesToReturn)
            }
        }
    }

    /// This function adds an entity to the local recentlyUsedEntity cache
    /// The entity will be given an expiry date before being added to the cache.
    ///
    /// Paramaters:
    /// entity - the entity to add to the local cache
    /// expiry - the number of minutes in which the entity data will be considered stale
    public func add(_ entity: MPOLKitEntity, withExpiry expiry: Int = RecentlyUsedEntityManager.StandardShelfLife) {

        entity.expiryDate = Date().adding(minutes: expiry)
        entityBucket.add(entity)
    }
}



