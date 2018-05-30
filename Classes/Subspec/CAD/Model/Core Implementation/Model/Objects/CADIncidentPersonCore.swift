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

    open var dateOfBirth: Date?

    open var firstName: String?

    open var fullAddress: String?

    open var gender: CADIncidentPersonGenderType?

    open var id: String?

    open var lastName: String?

    open var middleNames: String?

    open var source: String?

    open var thumbnailUrl: String?

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
        case dateOfBirth = "dateOfBirth"
        case firstName = "givenName"
        case fullAddress = "fullAddress"
        case gender = "gender"
        case id = "id"
        case lastName = "familyName"
        case middleNames = "middleNames"
        case source = "source"
        case thumbnailUrl = "thumbnailUrl"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .alertLevel)
        dateOfBirth = try values.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        fullAddress = try values.decodeIfPresent(String.self, forKey: .fullAddress)
        gender = try values.decodeIfPresent(CADIncidentPersonGenderCore.self, forKey: .gender)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        middleNames = try values.decodeIfPresent(String.self, forKey: .middleNames)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        thumbnailUrl = try values.decodeIfPresent(String.self, forKey: .thumbnailUrl)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

/// PSCore implementation of enum representing gender
public enum CADIncidentPersonGenderCore: String, Codable, CADIncidentPersonGenderType {
    case male = "M"
    case female = "F"
    case other = "O"

    /// The display title for the gender
    public var title: String {
        switch self {
        case .male:
            return NSLocalizedString("Male", comment: "")
        case .female:
            return NSLocalizedString("Female", comment: "")
        case .other:
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}
