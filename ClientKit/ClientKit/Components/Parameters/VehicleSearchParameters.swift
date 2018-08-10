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
    
    public init(registration: String, vehicleType: String, state: String) {
        var parameters: [String: Any] = ["plateNumber": registration]
        VehicleSearchParameters.appendAdditionalParameters(to: &parameters, vehicleType: vehicleType, state: state)
        super.init(parameters: parameters)
    }
    
    public init(vin: String, vehicleType: String, state: String) {
        var parameters: [String: Any] = ["vin": vin]
        VehicleSearchParameters.appendAdditionalParameters(to: &parameters, vehicleType: vehicleType, state: state)
        super.init(parameters: parameters)
    }

    public init(engineNumber: String, vehicleType: String, state: String) {
        var parameters: [String: Any] = ["engineNumber": engineNumber]
        VehicleSearchParameters.appendAdditionalParameters(to: &parameters, vehicleType: vehicleType, state: state)
        super.init(parameters: parameters)
    }

    private static func appendAdditionalParameters(to currentParameters: inout [String: Any], vehicleType: String, state: String) {
        if !vehicleType.isEmpty {
            currentParameters["vehicleType"] = vehicleType
        }
        if !state.isEmpty {
            currentParameters["state"] = state
        }
    }
}
