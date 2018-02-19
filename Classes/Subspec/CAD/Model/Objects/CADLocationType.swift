//
//  CADLocation.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADLocationType: class {

    // MARK: - Network
    var alertLevel : Int? { get }
    var country : String! { get }
    var fullAddress : String! { get }
    var latitude : Float! { get }
    var longitude : Float! { get }
    var postalCode : String! { get }
    var state : String! { get }
    var streetName : String! { get }
    var streetNumberFirst : String! { get }
    var streetNumberLast : String! { get }
    var streetType : String! { get }
    var suburb : String! { get }
}
