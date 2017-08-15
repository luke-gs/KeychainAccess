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
    
    public init(registration: String) {
        super.init(parameters: ["plateNumber": registration])
    }
    
    public init(vin: String) {
        super.init(parameters: ["vin": vin])
    }

    public init(engineNumber: String) {
        super.init(parameters: ["engineNumber": engineNumber])
    }
}

