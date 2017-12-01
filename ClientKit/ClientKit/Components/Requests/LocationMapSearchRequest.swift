//
//  LocationMapSearchRequest.swift
//  ClientKit
//
//  Created by RUI WANG on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public class LocationMapSearchRequest: AggregatedSearchRequest<Address> {
    public init(source: MPOLSource, request: EntitySearchRequest<Address>, sortHandler: ((Address, Address) -> Bool)? = nil) {
        super.init(source: source, request: request, sortHandler: sortHandler)
    }
    
    public override func searchPromise() -> Promise<SearchResult<Address>> {
        switch request {
        case _ as LocationMapRadiusSearchParameters:
            return APIManager.shared.locationRadiusSearch(in: source as! MPOLSource, with: request)
        default:
            break
        }
        
        return APIManager.shared.locationRadiusSearch(in: source as! MPOLSource, with: request)
    }
}
