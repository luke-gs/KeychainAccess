//
//  TestFancyDS.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit
import PromiseKit

class PersonRetrieveStrategy: EntityRetrieveStrategy {
    let source: MPOLSource

    init(source: MPOLSource) {
        self.source = source
    }

    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>? {
        guard let entity = entity as? Person else { return nil }

        if entity.source == source {
            // Reference entity is the same as source, retrieve details
            let request = EntityFetchRequest<Person>(id: entity.id)
            return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
                .then { person -> Promise<[EntityState]> in
                    return Promise.value([EntityState.detail(person)])
            }
        } else if let externalId = entity.externalIdentifiers?[source] {
            // Reference entity is not the same datasource as this strategy, retreive using its special id
            let request = EntityFetchRequest<Person>(id: externalId)
            return APIManager.shared.fetchEntityDetails(in: source, with: request)
                .then { person -> Promise<[EntityState]> in
                    return Promise.value([EntityState.detail(person)])
            }
        } else {
            // Reference entity has no speciealId, perform a regular search instead
            let request = PersonSearchParameters(familyName: entity.familyName!,
                                                 givenName: entity.givenName,
                                                 middleNames: entity.middleNames,
                                                 gender: entity.gender?.rawValue,
                                                 dateOfBirth: entity.dateOfBirth?.asPreferredDateString(),
                                                 age: entity.dateOfBirth?.dobAge() != nil ? "\(entity.dateOfBirth!.dobAge())" : nil)
            return APIManager.shared.searchEntity(in: source, with: request)
                .then { result -> Promise<[EntityState]> in
                    let people = result.results
                    let states = people.compactMap{EntityState.summary($0)}
                    return Promise.value(states)
            }
        }
    }
}

class VehicleRetrieveStrategy: EntityRetrieveStrategy {

    let source: MPOLSource

    init(source: MPOLSource) {
        self.source = source
    }

    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>? {
        guard let entity = entity as? Vehicle else { return nil }

        if entity.source == source {
            // Reference entity is the same as source, retrieve details
            let request = EntityFetchRequest<Vehicle>(id: entity.id)
            return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
                .then { vehicle -> Promise<[EntityState]> in
                    return Promise.value([EntityState.detail(vehicle)])
            }
        } else if let externalId = entity.externalIdentifiers?[source] {
            // Reference entity is not the same datasource as this strategy, retreive using its special id
            let request = EntityFetchRequest<Vehicle>(id: externalId)
            return APIManager.shared.fetchEntityDetails(in: source, with: request)
                .then { vehicle -> Promise<[EntityState]> in
                    return Promise.value([EntityState.detail(vehicle)])
            }
        } else {
            // Reference entity has no speciealId, perform a regular search instead
            let request = VehicleSearchParameters(registration: entity.registration!)

            return APIManager.shared.searchEntity(in: source, with: request)
                .then { result -> Promise<[EntityState]> in
                    let vehicles = result.results
                    let states = vehicles.compactMap{EntityState.summary($0)}
                    return Promise.value(states)
            }
        }
    }
}

class LocationRetrieveStrategy: EntityRetrieveStrategy {

    let source: MPOLSource

    init(source: MPOLSource) {
        self.source = source
    }

    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>? {
        guard let entity = entity as? Address else { return nil }

        let request = EntityFetchRequest<Address>(id: entity.id)
        return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
            .then { address -> Promise<[EntityState]> in
                return Promise.value([EntityState.detail(address)])
        }
    }
}

