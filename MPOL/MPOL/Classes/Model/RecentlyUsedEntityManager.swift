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

    public func add(_ entity: MPOLKitEntity) {

        //TODO: update when we get an actual expiry date for the data
        entity.expiryDate = Date().adding(minutes: RecentlyUsedEntityManager.StandardShelfLife)

        entityBucket.add(entity)
    }
}



