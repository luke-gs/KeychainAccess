//
//  VehicleRetrieveStrategy.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit
import MPOLKit

public class VehicleRetrieveStrategy: EntityRetrievalStrategy {

    public let source: MPOLSource

    public init(source: MPOLSource) {
        self.source = source
    }

    public func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>? {
        guard let entity = entity as? Vehicle else { return nil }

        if entity.source == source {
            // Reference entity is the same as source, retrieve details
            let request = EntityFetchRequest<Vehicle>(id: entity.id)
            return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
                .then { vehicle -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(vehicle)])
            }
        } else if let externalId = entity.externalIdentifiers?[source] {
            // Reference entity is not the same datasource as this strategy, retreive using its special id
            let request = EntityFetchRequest<Vehicle>(id: externalId)
            return APIManager.shared.fetchEntityDetails(in: source, with: request)
                .then { vehicle -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(vehicle)])
            }
        } else {
            // Reference entity has no speciealId, perform a regular search instead
            let request = VehicleSearchParameters(registration: entity.registration!)

            return APIManager.shared.searchEntity(in: source, with: request)
                .then { result -> Promise<[EntityResultState]> in
                    let vehicles = result.results
                    let states = vehicles.compactMap{EntityResultState.summary($0)}
                    return Promise.value(states)
            }
        }
    }
}
