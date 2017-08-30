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
        MPLUnimplemented()
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
    
}
