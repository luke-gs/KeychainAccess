//
//  CADIncidentPersonCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of class representing a person associated with incident
open class CADIncidentPersonCore: Codable, CADIncidentPersonType {

    public var entityType: String? {
        return "Person"
    }

    // MARK: - Network

    open var alertLevel: CADAlertLevelType?

    open var associatedAlertLevel: CADAlertLevelType?

    open var dateOfBirth: Date?

    open var firstName: String?

    open var fullAddress: String?

    open var gender: String?

    open var id: String?

    open var lastName: String?

    open var middleNames: String?

    open var source: String?

    open var thumbnail: String?

    // MARK: - Generated

    open var initials: String {
        return [String(firstName?.prefix(1)), String(lastName?.prefix(1))].joined(separator: "")
    }

    open var fullName: String {
        let lastFirst = [lastName, firstName].joined(separator: ", ")
        let middle = middleNames != nil ? "\(middleNames!.prefix(1))." : nil

        return [lastFirst, middle].joined()
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case alertLevel = "alertLevel"
        case associatedAlertLevel = "associatedAlertLevel"
        case dateOfBirth = "dateOfBirth"
        case firstName = "givenName"
        case fullAddress = "fullAddress"
        case gender = "gender"
        case id = "id"
        case lastName = "familyName"
        case middleNames = "middleNames"
        case source = "source"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .alertLevel)
        associatedAlertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .associatedAlertLevel)
        dateOfBirth = try values.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        fullAddress = try values.decodeIfPresent(String.self, forKey: .fullAddress)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        middleNames = try values.decodeIfPresent(String.self, forKey: .middleNames)
        source = try values.decodeIfPresent(String.self, forKey: .source)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

