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

    open var firstName: String?
    open var lastName: String?
    open var middleNames: String?
    open var dateOfBirth: Date?
    open var ethnicity: String?
    open var title: String?

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(id: String = UUID().uuidString) {
        super.init(id: id)
    }

    public required init(unboxer: Unboxer) throws {
        firstName = unboxer.unbox(key: "givenName")
        middleNames = unboxer.unbox(key: "middleNames")
        lastName = unboxer.unbox(key: "familyName")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: PersonAlias.dateTransformer)
        ethnicity = unboxer.unbox(key: "ethnicity")
        title = unboxer.unbox(key: "title")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        firstName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.firstName.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.middleNames.rawValue) as String?
        lastName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.lastName.rawValue) as String?
        dateOfBirth = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateOfBirth.rawValue) as Date?
        ethnicity = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.ethnicity.rawValue) as String?
        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
    }

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(firstName, forKey: CodingKey.firstName.rawValue)
        aCoder.encode(middleNames, forKey: CodingKey.middleNames.rawValue)
        aCoder.encode(lastName, forKey: CodingKey.lastName.rawValue)
        aCoder.encode(dateOfBirth, forKey: CodingKey.dateOfBirth.rawValue)
        aCoder.encode(ethnicity, forKey: CodingKey.ethnicity.rawValue)
        aCoder.encode(title, forKey: CodingKey.title.rawValue)
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

    private enum CodingKey: String {
        case firstName
        case middleNames
        case lastName
        case dateOfBirth
        case ethnicity
        case title
    }
}
