//
//  LocationRetrieveStrategy.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit
import MPOLKit

public class LocationRetrieveStrategy: EntityRetrieveStrategy {

    public let source: MPOLSource

    public init(source: MPOLSource) {
        self.source = source
    }

    public func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>? {
        guard let entity = entity as? Address else { return nil }

        let request = EntityFetchRequest<Address>(id: entity.id)
        return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
            .then { address -> Promise<[EntityState]> in
                return Promise.value([EntityState.detail(address)])
        }
    }
}
