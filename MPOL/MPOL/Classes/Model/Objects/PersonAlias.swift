//
//  PersonAlias.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Unbox

@objc(MPLPersonAlias)
open class PersonAlias: Alias {

    // MARK: - Properties

    open var dateOfBirth: Date?
    open var ethnicity: String?
    open var firstName: String?
    open var lastName: String?
    open var middleNames: String?
    open var title: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
        firstName = unboxer.unbox(key: "givenName")
        middleNames = unboxer.unbox(key: "middleNames")
        lastName = unboxer.unbox(key: "familyName")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: PersonAlias.dateTransformer)
        ethnicity = unboxer.unbox(key: "ethnicity")
        title = unboxer.unbox(key: "title")
        try super.init(unboxer: unboxer)
    }

    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""

        if let lastName = self.lastName?.ifNotEmpty() {
            formattedName += lastName

            if firstName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.firstName?.ifNotEmpty() {
            formattedName += givenName

            if middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }

        if let firstMiddleNameInitial = middleNames?.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }

        return formattedName

    }


    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case dateOfBirth
        case ethnicity
        case firstName
        case lastName
        case middleNames
        case title
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        ethnicity = try container.decodeIfPresent(String.self, forKey: .ethnicity)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        middleNames = try container.decodeIfPresent(String.self, forKey: .middleNames)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateOfBirth, forKey: CodingKeys.dateOfBirth)
        try container.encode(ethnicity, forKey: CodingKeys.ethnicity)
        try container.encode(firstName, forKey: CodingKeys.firstName)
        try container.encode(lastName, forKey: CodingKeys.lastName)
        try container.encode(middleNames, forKey: CodingKeys.middleNames)
        try container.encode(title, forKey: CodingKeys.title)
    }

}
