//
//  Person.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

@objc(MPLPerson)
open class Person: Entity {
    
    public enum Gender: Int, CustomStringConvertible, UnboxableEnum {
        case female, male, other
        
        public var description: String {
            switch self {
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .other:
                return "Other"
            }
        }
    }
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    open override var summary: String {
        return fullName ?? formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }
    
    open var givenName: String?
    open var surname: String?
    open var middleNames: [String]?
    
    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""
        
        let middleNames = self.middleNames?.filter { $0.isEmpty == false }
        
        if let surname = self.surname, surname.isEmpty == false {
            formattedName = surname
            
            if givenName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.givenName, givenName.isEmpty == false {
            formattedName += givenName
            
            if middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }
        if let firstMiddleNameInitial = middleNames?.first?.characters.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }
        
        return formattedName
    }
    
    
    open var dateOfBirth: Date?
    open var dateOfDeath: Date?
    
    open var gender: Gender?
    
    open var addresses: [Address]?
    
    open var licences: [Licence]?
    
    open var contacts: [Contact]?
    
    open var descriptions: [PersonDescription]?
    
    open var aliases: [Alias]?
    
    open var cautions: [Caution]?
    
    open var knownAssociates: [KnownAssociate]?
    
    open var warrants: [Warrant]?
    open var warnings: [Warning]?
    open var scarMarksTattoos: [ScarMarkTattoo]?
    
    // MARK: - ?
    open var highestAlertLevel: Alert.Level?
    open var fullName: String?
    open var matchScore: Int?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public required init(id: String = UUID().uuidString) {
        super.init(id: id)
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        do {
            try super.init(unboxer: unboxer)
        }

        givenName = unboxer.unbox(key: "givenName")
        surname = unboxer.unbox(key: "surname")
        middleNames = unboxer.unbox(key: "middleNames")

        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Person.dateTransformer)
        dateOfDeath = unboxer.unbox(key: "dateOfDeath", formatter: Person.dateTransformer)
     
        gender = unboxer.unbox(key: "gender")
        
        addresses = unboxer.unbox(key: "addresses")
        licences = unboxer.unbox(key: "licences")
        contacts = unboxer.unbox(key: "contacts")
        descriptions = unboxer.unbox(key: "descriptions")
        aliases = unboxer.unbox(key: "aliases")
        cautions = unboxer.unbox(key: "cautions")
        knownAssociates = unboxer.unbox(key: "knownAssociates")
        warrants = unboxer.unbox(key: "warrants")
        warnings = unboxer.unbox(key: "warnings")
        scarMarksTattoos = unboxer.unbox(key: "scarsMarksTattoos")
        
    }
    
    open override func encode(with aCoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
}
