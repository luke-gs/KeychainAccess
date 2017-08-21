//
//  VehicleFetchRequest.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public class VehicleFetchRequest: EntityDetailsFetchRequest<Vehicle> {
    
    public init(source: MPOLSource, request: EntityFetchRequest<Vehicle>) {
        super.init(source: source, request: request)
    }
    
    public override func fetchPromise() -> Promise<Vehicle> {
        return MPOLAPIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }
}
