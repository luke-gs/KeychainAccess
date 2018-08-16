//
//  PersonRetrieveStrategy.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit
import MPOLKit

public class PersonRetrieveStrategy: EntityRetrievalStrategy {
    public let source: MPOLSource

    public init(source: MPOLSource) {
        self.source = source
    }

    public func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>? {
        guard let entity = entity as? Person else { return nil }

        if entity.source == source {
            // Reference entity is the same as source, retrieve details
            let request = EntityFetchRequest<Person>(id: entity.id)
            return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
                .then { person -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(person)])
            }
        } else if let externalId = entity.externalIdentifiers?[source] {
            // Reference entity is not the same dataSource as this strategy, retreive using its special id
            let request = EntityFetchRequest<Person>(id: externalId)
            return APIManager.shared.fetchEntityDetails(in: source, with: request)
                .then { person -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(person)])
            }
        } else {
            // Reference entity has no specialId, perform a regular search instead
            let request = PersonSearchParameters(familyName: entity.familyName!,
                                                 givenName: entity.givenName,
                                                 middleNames: nil,
                                                 gender: nil,
                                                 dateOfBirth: nil,
                                                 age: nil)
            return APIManager.shared.searchEntity(in: source, with: request)
                .then { result -> Promise<[EntityResultState]> in
                    let people = result.results
                    let states = people.compactMap{EntityResultState.summary($0)}
                    return Promise.value(states)
            }
        }
    }
}
