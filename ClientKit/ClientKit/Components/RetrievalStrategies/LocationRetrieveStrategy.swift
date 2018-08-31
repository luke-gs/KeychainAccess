//
//  LocationRetrieveStrategy.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit
import PublicSafetyKit

public class LocationRetrieveStrategy: EntityRetrievalStrategy {

    public let source: MPOLSource

    public init(source: MPOLSource) {
        self.source = source
    }

    public func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>? {
        guard let entity = entity as? Address else { return nil }

        let request = EntityFetchRequest<Address>(id: entity.id)
        return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
            .then { address -> Promise<[EntityResultState]> in
                return Promise.value([EntityResultState.detail(address)])
        }
    }
}
