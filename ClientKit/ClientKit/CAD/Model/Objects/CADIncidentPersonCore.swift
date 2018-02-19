//
//  CADIncidentPersonCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for a single person in an incident
open class CADIncidentPersonCore: Codable, CADIncidentPersonType {

    // MARK: - Network

    public var alertLevel: Int!

    public var dateOfBirth: String!

    public var firstName: String!

    public var fullAddress: String!

    public var gender: String!

    public var id: String!

    public var lastName: String!

    public var middleNames: String!

    public var source: String!

    public var thumbnail: String!

    // MARK: - Generated

    open var initials: String {
        return [String(firstName?.prefix(1)), String(lastName?.prefix(1))].joined(separator: "")
    }

    open var fullName: String {
        let lastFirst = [lastName, firstName].joined(separator: ", ")
        let middle = middleNames != nil ? "\(middleNames.prefix(1))." : nil

        return [lastFirst, middle].joined()
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case alertLevel = "alertLevel"
        case dateOfBirth = "dateOfBirth"
        case firstName = "firstName"
        case fullAddress = "fullAddress"
        case gender = "gender"
        case id = "id"
        case lastName = "lastName"
        case middleNames = "middleNames"
        case source = "source"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(Int.self, forKey: .alertLevel)
        dateOfBirth = try values.decodeIfPresent(String.self, forKey: .dateOfBirth)
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

