//
//  CADIncidentPersonType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident person (association)
public protocol CADAssociatedPersonType: class, CADIncidentAssociationType {

    // MARK: - Network
    var alertLevel: CADAlertLevelType? { get set }
    var dateOfBirth: Date? { get set }
    var firstName: String? { get set }
    var fullAddress: String? { get set }
    var gender: CADPersonGenderType? { get set }
    var lastName: String? { get set }
    var middleNames: String? { get set }
    var thumbnailUrl: URL? { get set }

    // MARK: - Generated
    var fullName: String { get }
    var initials: String { get }
}

/// Protocol for an enum representing a gender
public protocol CADPersonGenderType: CADEnumStringType {

    /// The display title for the gender
    var title: String { get }
}
