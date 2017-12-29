//
//  VehicleFetchRequest.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import MPOLKit

public class VehicleFetchRequest: EntityDetailFetchRequest<Vehicle> {

    public override func fetchPromise() -> Promise<Vehicle> {
        return APIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }

}
