//
//  CADIncidentVehicleType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADIncidentVehicleType {
    var alertLevel : Int! { get }
    var vehicleDescription : String! { get }
    var vehicleType : String! { get }
    var color: String! { get }
    var bodyType: String! { get }
    var stolen: Bool! { get }
    var plateNumber : String! { get }
}
