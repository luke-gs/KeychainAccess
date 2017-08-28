//
//  VehicleSearchRequest.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public class VehicleSearchRequest: AggregatedSearchRequest<Vehicle> {
    
    public init(source: MPOLSource, request: EntitySearchRequest<Vehicle>, sortHandler: ((Vehicle, Vehicle) -> Bool)? = nil) {
        super.init(source: source, request: request, sortHandler: sortHandler)
    }

    public override func searchPromise() -> Promise<SearchResult<Vehicle>> {
        // swiftlint:disable force_cast
        return APIManager.shared.searchEntity(in: source as! MPOLSource, with: request)
        // swiftlint:enable force_cast
    }

}
