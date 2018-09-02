//
//  OrganisationRetrieveStrategy.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PromiseKit
import PublicSafetyKit

public class OrganisationRetrieveStrategy: EntityRetrievalStrategy {
    
    public let source: MPOLSource
    
    public init(source: MPOLSource) {
        self.source = source
    }
    
    public func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>? {
        guard let entity = entity as? Organisation else { return nil }
        
        if entity.source == source {
            // Reference entity is the same as source, retrieve details
            let request = EntityFetchRequest<Organisation>(id: entity.id)
            return APIManager.shared.fetchEntityDetails(in: entity.source!, with: request)
                .then { organisation -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(organisation)])
            }
        } else if let externalId = entity.externalIdentifiers?[source] {
            // Reference entity is not the same dataSource as this strategy, retreive using its special id
            let request = EntityFetchRequest<Organisation>(id: externalId)
            return APIManager.shared.fetchEntityDetails(in: source, with: request)
                .then { organisation -> Promise<[EntityResultState]> in
                    return Promise.value([EntityResultState.detail(organisation)])
            }
        } else {
            // Reference entity has no speciealId, perform a regular search instead
            let request = OrganisationSearchParameters(name: entity.name!)
            
            return APIManager.shared.searchEntity(in: source, with: request)
                .then { result -> Promise<[EntityResultState]> in
                    let organisations = result.results
                    let states = organisations.compactMap{EntityResultState.summary($0)}
                    return Promise.value(states)
            }
        }
    }
}
