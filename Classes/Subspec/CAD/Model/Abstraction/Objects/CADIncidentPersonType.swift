//
//  CADIncidentPersonType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident person (association)
public protocol CADIncidentPersonType: class, CADIncidentAssociationType {

    // MARK: - Network
    var alertLevel: Int? { get set }
    var dateOfBirth: String? { get set }
    var firstName: String? { get set }
    var fullAddress: String? { get set }
    var gender: String? { get set }
    var lastName: String? { get set }
    var middleNames: String? { get set }
    var thumbnail: String? { get set }

    // MARK: - Generated
    var fullName: String { get }
    var initials: String { get }
}
