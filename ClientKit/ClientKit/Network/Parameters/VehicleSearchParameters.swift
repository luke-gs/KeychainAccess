//
//  VehicleSearchParameters.swift
//  MPOLKit
//
//  Created by Herli Halim on 8/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Wrap

public struct VehicleSearchParameters: Parameterisable {
        
    let registration: String?
    let year: String?
    let make: String?
    let model: String?
    
    public var parameters: [String: Any] {
        return try! wrap(self)
    }
}

