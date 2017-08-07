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
    
    public init(criteria: String) {
        let parameterisable = SearchParameters(criteria: criteria)
        super.init(parameters: parameterisable.parameters)
    }

    private struct SearchParameters: Parameterisable {
        public let criteria: String
        
        public var parameters: [String: Any] {
            return try! wrap(self)
        }
    }

}

