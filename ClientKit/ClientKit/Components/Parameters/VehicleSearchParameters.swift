//
//  VehicleSearchParameter.swift
//  MPOL
//
//  Created by Herli Halim on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import Wrap


public class VehicleSearchParameters: EntitySearchRequest<Vehicle> {
    
    public init(registration: String, vehicleType: String) {
        var parameters: [String : Any] = ["plateNumber": registration]
        if !vehicleType.isEmpty {
            parameters["vehicleType"] = vehicleType
        }
        super.init(parameters: parameters)
    }
    
    public init(vin: String, vehicleType: String) {
        var parameters: [String : Any] = ["vin": vin]
        if !vehicleType.isEmpty {
            parameters["vehicleType"] = vehicleType
        }
        super.init(parameters: parameters)
    }

    public init(engineNumber: String, vehicleType: String) {
        var parameters: [String : Any] = ["engineNumber": engineNumber]
        if !vehicleType.isEmpty {
            parameters["vehicleType"] = vehicleType
        }
        super.init(parameters: parameters)
    }
}

