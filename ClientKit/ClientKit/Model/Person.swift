//
//  Person.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import MPOLKit

@objc(MPLPerson)
open class Person: Entity {

    private enum Coding: String {
        case givenName = "givenName"
        case surname = "surname"
        case middleNames = "middleNames"
        case initials = "initials"
        case dateOfBirth = "dateOfBirth"
        case dateOfDeath = "dateOfDeath"
        case yearOnlyDateOfBirth = "yearOnlyDateOfBirth"
        case gender = "gender"
        case contacts = "contacts"
        case licences = "licences"
        case descriptions = "descriptions"
        case aliases = "aliases"
        case actions = "actions"
        case interventionOrders = "interventionOrders"
        case bailOrders = "bailOrders"
        case fieldContacts = "fieldContacts"
        case missingPersonReports = "missingPersonReports"
        case familyIncidents = "familyIncidents"
        case criminalHistory = "criminalHistory"
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
    open var surname: String?
    open var middleNames: String?
    open var initials: String?
    
    open var dateOfBirth: Date?
    open var dateOfDeath: Date?
    open var yearOnlyDateOfBirth: Bool?
    
    open var gender: Gender?
    
    open var contacts: [Contact]?
    open var licences: [Licence]?
    open var descriptions: [PersonDescription]?
    open var aliases: [Alias]?
    
    // TODO: TEMP
    open var criminalHistory: [CriminalHistory]?

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
        surname = aDecoder.decodeObject(of: NSString.self, forKey: Coding.surname.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: Coding.middleNames.rawValue) as String?
        initials = aDecoder.decodeObject(of: NSString.self, forKey: Coding.initials.rawValue) as String?
        dateOfBirth = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateOfBirth.rawValue) as Date?
        dateOfDeath = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateOfDeath.rawValue) as Date?
        yearOnlyDateOfBirth = aDecoder.decodeObject(forKey: Coding.yearOnlyDateOfBirth.rawValue) as! Bool?

        if let gender = aDecoder.decodeObject(of: NSString.self, forKey: Coding.gender.rawValue) as String? {
            self.gender = Gender(rawValue: gender)
        }

        contacts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.contacts.rawValue) as? [Contact]
        licences = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.licences.rawValue) as? [Licence]
        descriptions = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.descriptions.rawValue) as? [PersonDescription]
        aliases = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.aliases.rawValue) as? [Alias]
    }

    public required override init(id: String = UUID().uuidString) {
        super.init(id: id)
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        
        try super.init(unboxer: unboxer)

        givenName = unboxer.unbox(key: "givenName")
        surname = unboxer.unbox(key: "familyName")
        middleNames = unboxer.unbox(key: "middleNames")

        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Person.dateTransformer)
        dateOfDeath = unboxer.unbox(key: "dateOfDeath", formatter: Person.dateTransformer)
        yearOnlyDateOfBirth = unboxer.unbox(key: "yearOnlyDateOfBirth")
        
        gender = unboxer.unbox(key: "gender")
        
        licences = unboxer.unbox(key: "licences")
        contacts = unboxer.unbox(key: "contactDetails")
        descriptions = unboxer.unbox(key: "descriptions")
        aliases = unboxer.unbox(key: "aliases")

        criminalHistory = unboxer.unbox(key: "criminalHistory")

        
        if let initials: String = unboxer.unbox(key: "initials") {
            self.initials = initials
        } else {
            var initials = ""
            if let givenName = givenName?.ifNotEmpty() {
                initials += givenName[...givenName.startIndex]
            }
            if let surname = surname?.ifNotEmpty() {
                initials += surname[...surname.startIndex]
            }
            if initials.isEmpty == false {
                self.initials = initials
            }
        }
        
        isAlias = unboxer.unbox(key: "isAlias")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(givenName, forKey: Coding.givenName.rawValue)
        aCoder.encode(surname, forKey: Coding.surname.rawValue)
        aCoder.encode(middleNames, forKey: Coding.middleNames.rawValue)
        aCoder.encode(initials, forKey: Coding.initials.rawValue)
        aCoder.encode(dateOfBirth, forKey: Coding.dateOfBirth.rawValue)
        aCoder.encode(dateOfDeath, forKey: Coding.dateOfDeath.rawValue)
        if yearOnlyDateOfBirth != nil {
            aCoder.encode(yearOnlyDateOfBirth!, forKey: Coding.yearOnlyDateOfBirth.rawValue)
        }
        aCoder.encode(gender?.rawValue, forKey: Coding.gender.rawValue)
        aCoder.encode(contacts, forKey: Coding.contacts.rawValue)
        aCoder.encode(licences, forKey: Coding.licences.rawValue)
        aCoder.encode(descriptions, forKey: Coding.descriptions.rawValue)
        aCoder.encode(aliases, forKey: Coding.aliases.rawValue)
        aCoder.encode(criminalHistory, forKey: Coding.criminalHistory.rawValue)
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
    
}
