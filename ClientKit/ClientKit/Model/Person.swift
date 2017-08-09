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
    
    override open class var serverTypeRepresentation: String {
        return "person"
    }

    public enum Gender: Int, CustomStringConvertible, UnboxableEnum, Pickable {
        case female, male, other
        
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
    
    open var gender: Gender?
    
    open var addresses: [Address]?
    open var address: Address?
    
    open var phoneNumbers: [PhoneNumber]?
    
    open var licences: [Licence]?
    
    open var contacts: [Contact]?
    
    open var descriptions: [PersonDescription]?
    
    open var aliases: [Alias]?
    
    open var cautions: [Caution]?
    
    open var knownAssociates: [KnownAssociate]?
    //open var associatedPersons: [Person]?
    
    open var warrants: [Warrant]?
    open var warnings: [Warning]?
    open var scarMarksTattoos: [ScarMarkTattoo]?
    
    open var actions: [Action]?
    open var events: [Event]?
    open var interventionOrders: [InterventionOrder]?
    open var bailOrders: [BailOrder]?
    open var fieldContacts: [FieldContact]?
    open var whereabouts: [Whereabouts]?
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
    open var fullName: String?
    open var matchScore: Int = 0
    open var ethnicity: String?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required override init(id: String = UUID().uuidString) {
        super.init(id: id)
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        
        try super.init(unboxer: unboxer)

        givenName = unboxer.unbox(key: "givenName")
        surname = unboxer.unbox(key: "surname")
        middleNames = unboxer.unbox(key: "middleNames")
        fullName    = unboxer.unbox(key: "fullName")

        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Person.dateTransformer)
        dateOfDeath = unboxer.unbox(key: "dateOfDeath", formatter: Person.dateTransformer)
     
        gender = unboxer.unbox(key: "gender")
        
        addresses = unboxer.unbox(key: "addresses")
        phoneNumbers = unboxer.unbox(key: "phoneNumbers")
        licences = unboxer.unbox(key: "licences")
        contacts = unboxer.unbox(key: "contacts")
        descriptions = unboxer.unbox(key: "descriptions")
        aliases = unboxer.unbox(key: "aliases")
        cautions = unboxer.unbox(key: "cautions")
        knownAssociates = unboxer.unbox(key: "knownAssociates")
        warrants = unboxer.unbox(key: "warrants")
        warnings = unboxer.unbox(key: "warnings")
        scarMarksTattoos = unboxer.unbox(key: "scarsMarksTattoos")
        
        interventionOrders = unboxer.unbox(key: "interventionOrders")
        bailOrders = unboxer.unbox(key: "bailOrders")
        fieldContacts = unboxer.unbox(key: "fieldContacts")
        whereabouts = unboxer.unbox(key: "whereabouts")
        missingPersonReports = unboxer.unbox(key: "missingPersonReports")
        familyIncidents = unboxer.unbox(key: "familyIncidents")
        
        criminalHistory = unboxer.unbox(key: "criminalHistory")
        
        events = unboxer.unbox(key: "events")
        actions = unboxer.unbox(key: "actions")
       // associatedPersons = unboxer.unbox(key: "persons")
        address = unboxer.unbox(key: "address")
        
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
        ethnicity = unboxer.unbox(key: "ethnicity")
        matchScore = unboxer.unbox(key: "nameScore") ?? 0
    }
    
    open override func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
    
}
