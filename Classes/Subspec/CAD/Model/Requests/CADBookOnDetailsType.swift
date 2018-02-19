//
//  BookOnDetails.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBookOnDetailsType: class {

    // MARK: - Network
    var callsign: String! { get set }
    var category: String! { get set }
    var driverpayrollId: String! { get set }
    var equipment: [CADEquipmentType]! { get set }
    var fleetNumber: String! { get set }
    var loggedInpayrollId: String! { get set }
    var odometer: String! { get set }
    var officers: [CADOfficerType]! { get set }
    var remarks: String! { get set }
    var serial: String! { get set }
    var shiftEnd: Date! { get set }
    var shiftStart: Date! { get set }

    // MARK: - Init

    /// Default constructor
    init()

    /// Copy constructor (deep)
    init(request: CADBookOnDetailsType)
}
