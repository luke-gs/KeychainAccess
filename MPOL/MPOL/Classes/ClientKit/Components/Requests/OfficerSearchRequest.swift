//
//  OfficerSearchRequest.swift
//  ClientKit
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

public class OfficerSearchRequest: AggregatedSearchRequest<Officer> {

    public init(source: MPOLSource, request: EntitySearchRequest<Officer>, sortHandler: ((Officer, Officer) -> Bool)? = nil) {
        super.init(source: source, request: request, sortHandler: sortHandler)
    }

    public override func searchPromise() -> Promise<SearchResult<Officer>> {
        return APIManager.shared.searchEntity(in: source as! MPOLSource, with: request)

    }

    public  func searchPromise(withCancellationToken token: PromiseCancellationToken? = nil) -> Promise<SearchResult<Officer>> {
        return APIManager.shared.searchEntity(in: source as! MPOLSource, with: request, withCancellationToken: token)
    }

}

public class CurrentOfficerDetailsFetchRequest: Requestable {
    public typealias ResultClass = Officer
    public var parameters: [String: Any] = [:]
    public init() {}
}
