//
//  Matches.swift
//  ClientKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

struct PersonMatchStrategy: DataMatchable {

    let initialSource: EntitySource
    let resultSource: EntitySource

    func match(_ entity: MPOLKitEntity) -> Fetchable? {
        guard let entity = entity as? Person,
            let resultSource = resultSource as? MPOLSource,
            let matchingIdentifier = entity.externalIdentifiers?[resultSource] else {
            return nil
        }

        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: matchingIdentifier))
        return EntityDetailFetch<Person>(request: request)
    }

}
