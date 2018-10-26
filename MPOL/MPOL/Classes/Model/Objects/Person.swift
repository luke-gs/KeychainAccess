//
//  Person.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import PublicSafetyKit

@objc(MPLPerson)
open class Person: Entity, Identifiable {

    // MARK: - Class

    override open class var serverTypeRepresentation: String {
        return "person"
    }

    open override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    public enum Gender: String, CustomStringConvertible, UnboxableEnum, Codable, Pickable {
        case female = "F"
        case male = "M"
        case other = "O"

        public var description: String {
            switch self {
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .other:
                return "Unknown"
            }
        }

        public var title: String? { return description }
        public var subtitle: String? { return nil }
        public static let allCases: [Gender] = [.female, .male, .other]
    }

    public required override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Properties

    open var aliases: [PersonAlias]?
    open var contacts: [Contact]?
    open var dateOfBirth: Date?
    open var dateOfDeath: Date?
    open var descriptions: [PersonDescription]?
    open var familyName: String?
    open var gender: Gender?
    open var givenName: String?
    open var isAlias: Bool?
    open var licences: [Licence]?
    open var middleNames: String?
    open var offenderCharges: [OffenderCharge]?
    open var offenderConvictions: [OffenderConviction]?
    open var orders: [Order]?
    open var thumbnailUrl: URL?
    open var trafficHistory: [TrafficHistory]?
    open var yearOnlyDateOfBirth: Bool?

    // MARK: - Transient

    open var thumbnail: UIImage?

    internal lazy var initialThumbnail: UIImage = { [unowned self] in
        if let initials = self.initials?.ifNotEmpty() {
            return UIImage.thumbnail(withInitials: initials)
        }
        return UIImage()
    }()

    // MARK: - Calculated

    open var isDeceased: Bool {
        return dateOfDeath != nil
    }

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {

        try super.init(unboxer: unboxer)

        givenName = unboxer.unbox(key: "givenName")
        familyName = unboxer.unbox(key: "familyName")
        middleNames = unboxer.unbox(key: "middleNames")

        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Person.dateTransformer)
        dateOfDeath = unboxer.unbox(key: "dateOfDeath", formatter: Person.dateTransformer)
        yearOnlyDateOfBirth = unboxer.unbox(key: "yearOnlyDateOfBirth")

        gender = unboxer.unbox(key: "gender")
        if let urlString: String = unboxer.unbox(key: "thumbnailUrl") {
            thumbnailUrl = URL(string: urlString)
        }

        licences = unboxer.unbox(key: "licences")
        contacts = unboxer.unbox(key: "contactDetails")
        descriptions = unboxer.unbox(key: "descriptions")
        aliases = unboxer.unbox(key: "aliases")

        isAlias = unboxer.unbox(key: "isAlias")
        orders = unboxer.unbox(key: CodingKeys.orders.rawValue)

        offenderCharges = unboxer.unbox(key: CodingKeys.offenderCharges.rawValue)
        offenderConvictions = unboxer.unbox(key: CodingKeys.offenderConvictions.rawValue)
        trafficHistory = unboxer.unbox(key: CodingKeys.trafficHistory.rawValue)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case aliases
        case contacts
        case dateOfBirth
        case dateOfDeath
        case descriptions
        case familyName = "surname"
        case gender
        case givenName
        case isAlias
        case licences
        case middleNames
        case offenderCharges
        case offenderConvictions
        case orders
        case thumbnailUrl
        case trafficHistory
        case yearOnlyDateOfBirth
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        aliases = try container.decodeIfPresent([PersonAlias].self, forKey: .aliases)
        contacts = try container.decodeIfPresent([Contact].self, forKey: .contacts)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        dateOfDeath = try container.decodeIfPresent(Date.self, forKey: .dateOfDeath)
        descriptions = try container.decodeIfPresent([PersonDescription].self, forKey: .descriptions)
        familyName = try container.decodeIfPresent(String.self, forKey: .familyName)
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        givenName = try container.decodeIfPresent(String.self, forKey: .givenName)
        isAlias = try container.decodeIfPresent(Bool.self, forKey: .isAlias)
        licences = try container.decodeIfPresent([Licence].self, forKey: .licences)
        middleNames = try container.decodeIfPresent(String.self, forKey: .middleNames)
        offenderCharges = try container.decodeIfPresent([OffenderCharge].self, forKey: .offenderCharges)
        offenderConvictions = try container.decodeIfPresent([OffenderConviction].self, forKey: .offenderConvictions)
        orders = try container.decodeIfPresent([Order].self, forKey: .orders)
        thumbnailUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailUrl)
        trafficHistory = try container.decodeIfPresent([TrafficHistory].self, forKey: .trafficHistory)
        yearOnlyDateOfBirth = try container.decodeIfPresent(Bool.self, forKey: .yearOnlyDateOfBirth)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aliases, forKey: CodingKeys.aliases)
        try container.encode(contacts, forKey: CodingKeys.contacts)
        try container.encode(dateOfBirth, forKey: CodingKeys.dateOfBirth)
        try container.encode(dateOfDeath, forKey: CodingKeys.dateOfDeath)
        try container.encode(descriptions, forKey: CodingKeys.descriptions)
        try container.encode(familyName, forKey: CodingKeys.familyName)
        try container.encode(gender, forKey: CodingKeys.gender)
        try container.encode(givenName, forKey: CodingKeys.givenName)
        try container.encode(isAlias, forKey: CodingKeys.isAlias)
        try container.encode(licences, forKey: CodingKeys.licences)
        try container.encode(middleNames, forKey: CodingKeys.middleNames)
        try container.encode(offenderCharges, forKey: CodingKeys.offenderCharges)
        try container.encode(offenderConvictions, forKey: CodingKeys.offenderConvictions)
        try container.encode(orders, forKey: CodingKeys.orders)
        try container.encode(thumbnailUrl, forKey: CodingKeys.thumbnailUrl)
        try container.encode(trafficHistory, forKey: CodingKeys.trafficHistory)
        try container.encode(yearOnlyDateOfBirth, forKey: CodingKeys.yearOnlyDateOfBirth)
    }

}
