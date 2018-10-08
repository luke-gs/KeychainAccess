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

    private enum Coding: String {
        case givenName = "givenName"
        case surname = "surname"
        case middleNames = "middleNames"
        case initials = "initials"
        case dateOfBirth = "dateOfBirth"
        case dateOfDeath = "dateOfDeath"
        case yearOnlyDateOfBirth = "yearOnlyDateOfBirth"
        case gender = "gender"
        case thumbnailUrl = "thumbnailUrl"
        case contacts = "contacts"
        case licences = "licences"
        case descriptions = "descriptions"
        case aliases = "aliases"
        case offenderCharges
        case offenderConvictions
        case orders = "orders"
        case trafficHistory
    }

    override open class var serverTypeRepresentation: String {
        return "person"
    }

    public enum Gender: String, CustomStringConvertible, UnboxableEnum, Pickable {
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
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    open var givenName: String?
    open var familyName: String?
    open var middleNames: String?

    open var dateOfBirth: Date?
    open var dateOfDeath: Date?
    open var yearOnlyDateOfBirth: Bool?
    
    open var gender: Gender?
    open var thumbnailUrl: URL?
    
    open var contacts: [Contact]?
    open var licences: [Licence]?
    open var descriptions: [PersonDescription]?
    open var aliases: [PersonAlias]?

    open var orders: [Order]?

    open var offenderCharges: [OffenderCharge]?
    open var offenderConvictions: [OffenderConviction]?

    open var trafficHistory: [TrafficHistory]?

    open var isAlias: Bool?
    open var thumbnail: UIImage?

    internal lazy var initialThumbnail: UIImage = { [unowned self] in
        if let initials = self.initials?.ifNotEmpty() {            
            return UIImage.thumbnail(withInitials: initials)
        }
        return UIImage()
    }()
    
    // MARK: - ?
    open var highestAlertLevel: Alert.Level?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        givenName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.givenName.rawValue) as String?
        familyName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.surname.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: Coding.middleNames.rawValue) as String?
        dateOfBirth = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateOfBirth.rawValue) as Date?
        dateOfDeath = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateOfDeath.rawValue) as Date?
        yearOnlyDateOfBirth = aDecoder.decodeObject(forKey: Coding.yearOnlyDateOfBirth.rawValue) as! Bool?

        if let gender = aDecoder.decodeObject(of: NSString.self, forKey: Coding.gender.rawValue) as String? {
            self.gender = Gender(rawValue: gender)
        }
        thumbnailUrl = aDecoder.decodeObject(of: NSURL.self, forKey: Coding.thumbnailUrl.rawValue) as URL?

        contacts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.contacts.rawValue) as? [Contact]
        licences = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.licences.rawValue) as? [Licence]
        descriptions = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.descriptions.rawValue) as? [PersonDescription]
        aliases = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.aliases.rawValue) as? [PersonAlias]
        orders = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.orders.rawValue) as? [Order]

        offenderCharges = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.orders.rawValue) as? [OffenderCharge]
        offenderConvictions = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.orders.rawValue) as? [OffenderConviction]
        trafficHistory = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.trafficHistory.rawValue) as? [TrafficHistory]
    }

    public required override init(id: String = UUID().uuidString) {
        super.init(id: id)
    }
    
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
        orders = unboxer.unbox(key: Coding.orders.rawValue)

        offenderCharges = unboxer.unbox(key: Coding.offenderCharges.rawValue)
        offenderConvictions = unboxer.unbox(key: Coding.offenderConvictions.rawValue)
        trafficHistory = unboxer.unbox(key: Coding.trafficHistory.rawValue)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(givenName, forKey: Coding.givenName.rawValue)
        aCoder.encode(familyName, forKey: Coding.surname.rawValue)
        aCoder.encode(middleNames, forKey: Coding.middleNames.rawValue)
        aCoder.encode(dateOfBirth, forKey: Coding.dateOfBirth.rawValue)
        aCoder.encode(dateOfDeath, forKey: Coding.dateOfDeath.rawValue)
        if yearOnlyDateOfBirth != nil {
            aCoder.encode(yearOnlyDateOfBirth!, forKey: Coding.yearOnlyDateOfBirth.rawValue)
        }
        aCoder.encode(gender?.rawValue, forKey: Coding.gender.rawValue)
        aCoder.encode(thumbnailUrl, forKey: Coding.thumbnailUrl.rawValue)
        aCoder.encode(contacts, forKey: Coding.contacts.rawValue)
        aCoder.encode(licences, forKey: Coding.licences.rawValue)
        aCoder.encode(descriptions, forKey: Coding.descriptions.rawValue)
        aCoder.encode(aliases, forKey: Coding.aliases.rawValue)
        aCoder.encode(orders, forKey: Coding.orders.rawValue)
        aCoder.encode(offenderCharges, forKey: Coding.offenderCharges.rawValue)
        aCoder.encode(offenderConvictions, forKey: Coding.offenderConvictions.rawValue)
        aCoder.encode(trafficHistory, forKey: Coding.trafficHistory.rawValue)
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }

}
