//
//  OrganisationFetchRequest.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

public class OrganisationSearchRequest: AggregatedSearchRequest<Organisation> {
    public init(source: MPOLSource, request: EntitySearchRequest<Organisation>, sortHandler: ((Organisation, Organisation) -> Bool)? = nil) {
        super.init(source: source, request: request, sortHandler: sortHandler)
    }
    
    public override func searchPromise() -> Promise<SearchResult<Organisation>> {
        // swiftlint:disable force_cast
        return APIManager.shared.searchEntity(in: source as! MPOLSource, with: request)
        // swiftlint:enable force_cast
    }
}
