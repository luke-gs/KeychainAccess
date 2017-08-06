//
//  PersonSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

private let searchTypeKey  = "searchType"
private let statesKey      = "states"
private let makesKey       = "makes"
private let modelsKey      = "models"

@objc(MPLVehicleSearchRequest)
class VehicleSearchRequest: SearchRequest {
    override func searchOperation(forSource source: EntitySource,
                                  params: Parameterisable,
                                  completion: ((_ entities: [MPOLKitEntity]?, _ error: Error?)->())?) throws
    {
        //TODO: New network stuff
    }
}
