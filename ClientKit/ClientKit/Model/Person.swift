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
        case GivenName = "GivenName"
        case Surname = "Surname"
        case MiddleNames = "MiddleNames"
        case Initials = "Initials"
        case DateOfBirth = "DateOfBirth"
        case DateOfDeath = "DateOfDeath"
        case YearOnlyDateOfBirth = "YearOnlyDateOfBirth"
        case Gender = "Gender"
        case Contacts = "Contacts"
        case Licences = "Licences"
        case Descriptions = "Descriptions"
        case Aliases = "Aliases"
        case Actions = "Actions"
        case InterventionOrders = "InterventionOrders"
        case BailOrders = "BailOrders"
        case FieldContacts = "FieldContacts"
        case MissingPersonReports = "MissingPersonReports"
        case FamilyIncidents = "FamilyIncidents"
        case CriminalHistory = "CriminalHistory"
    }

    override open class var serverTypeRepresentation: String {
        return "person"
    }

    public enum Gender: String, CustomStringConvertible, UnboxableEnum, Pickable {
        case female = "F"
        case male = "M"
        case other
        
        public var description: String {
            switch self {
            case .female:
                return "Female"
            case .male:
                return "Male"
            default:
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
    open var actions: [Action]?
    open var interventionOrders: [InterventionOrder]?
    open var bailOrders: [BailOrder]?
    open var fieldContacts: [FieldContact]?
    open var missingPersonReports: [MissingPersonReport]?
    open var familyIncidents: [FamilyIncident]?
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
        givenName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.GivenName.rawValue) as String?
        surname = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Surname.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: Coding.MiddleNames.rawValue) as String?
        initials = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Initials.rawValue) as String?
        dateOfBirth = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.DateOfBirth.rawValue) as Date?
        dateOfDeath = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.DateOfDeath.rawValue) as Date?
        yearOnlyDateOfBirth = aDecoder.decodeObject(forKey: Coding.YearOnlyDateOfBirth.rawValue) as! Bool?

        if let gender = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Gender.rawValue) as String? {
            self.gender = Gender(rawValue: gender)
        }

        contacts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.Contacts.rawValue) as? [Contact]
        licences = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.Licences.rawValue) as? [Licence]
        descriptions = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.Descriptions.rawValue) as? [PersonDescription]
        aliases = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.Aliases.rawValue) as? [Alias]
        actions = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.Actions.rawValue) as? [Action]
        interventionOrders = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.InterventionOrders.rawValue) as? [InterventionOrder]
        bailOrders = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.BailOrders.rawValue) as? [BailOrder]
        fieldContacts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.FieldContacts.rawValue) as? [FieldContact]
        missingPersonReports = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.MissingPersonReports.rawValue) as? [MissingPersonReport]
        familyIncidents = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.FamilyIncidents.rawValue) as? [FamilyIncident]
        criminalHistory = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.CriminalHistory.rawValue) as? [CriminalHistory]
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
        
        // TODO: ?
        
        // Temporary keep them
        actions = unboxer.unbox(key: "actions")
        interventionOrders = unboxer.unbox(key: "interventionOrders")
        bailOrders = unboxer.unbox(key: "bailOrders")
        fieldContacts = unboxer.unbox(key: "fieldContacts")
        missingPersonReports = unboxer.unbox(key: "missingPersonReports")
        familyIncidents = unboxer.unbox(key: "familyIncidents")
        criminalHistory = unboxer.unbox(key: "criminalHistory")

        
        if let initials: String = unboxer.unbox(key: "initials") {
            self.initials = initials
        } else {
            var initials = ""
            if let givenName = givenName?.ifNotEmpty() {
                initials += givenName.substring(to: givenName.index(after: givenName.startIndex))
            }
            if let surname = surname?.ifNotEmpty() {
                initials += surname.substring(to: surname.index(after: surname.startIndex))
            }
            if initials.isEmpty == false {
                self.initials = initials
            }
        }
        
        isAlias = unboxer.unbox(key: "isAlias")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(givenName, forKey: Coding.GivenName.rawValue)
        aCoder.encode(surname, forKey: Coding.Surname.rawValue)
        aCoder.encode(middleNames, forKey: Coding.MiddleNames.rawValue)
        aCoder.encode(initials, forKey: Coding.Initials.rawValue)
        aCoder.encode(dateOfBirth, forKey: Coding.DateOfBirth.rawValue)
        aCoder.encode(dateOfDeath, forKey: Coding.DateOfDeath.rawValue)
        if yearOnlyDateOfBirth != nil { aCoder.encode(yearOnlyDateOfBirth!, forKey: Coding.YearOnlyDateOfBirth.rawValue) }
        aCoder.encode(gender?.rawValue, forKey: Coding.Gender.rawValue)
        aCoder.encode(contacts, forKey: Coding.Contacts.rawValue)
        aCoder.encode(licences, forKey: Coding.Licences.rawValue)
        aCoder.encode(descriptions, forKey: Coding.Descriptions.rawValue)
        aCoder.encode(aliases, forKey: Coding.Aliases.rawValue)
        aCoder.encode(actions, forKey: Coding.Actions.rawValue)
        aCoder.encode(interventionOrders, forKey: Coding.InterventionOrders.rawValue)
        aCoder.encode(bailOrders, forKey: Coding.BailOrders.rawValue)
        aCoder.encode(fieldContacts, forKey: Coding.FieldContacts.rawValue)
        aCoder.encode(missingPersonReports, forKey: Coding.MissingPersonReports.rawValue)
        aCoder.encode(familyIncidents, forKey: Coding.FamilyIncidents.rawValue)
        aCoder.encode(criminalHistory, forKey: Coding.CriminalHistory.rawValue)
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
    
}
