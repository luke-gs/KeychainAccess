//
//  CADIncidentPersonType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADIncidentPersonType {
    var alertLevel: Int! { get }
    var dateOfBirth: String! { get }
    var firstName: String! { get }
    var middleNames: String! { get }
    var lastName: String! { get }
    var fullAddress: String! { get }
    var gender: String! { get }
    var thumbnail: String! { get }

    var initials: String { get }
    var fullName: String { get }
}
