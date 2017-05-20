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
        return formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }
    
    open var givenName: String?
    open var familyName: String?
    
    open var formattedName: String? {
        var names = [String]()
        if let familyName = self.familyName {
            names.append(familyName)
        }
        if let givenName = self.givenName {
            names.append(givenName)
        }
        return names.joined(separator: ", ")
    }
    
    open var dateOfBirth: Date?
    open var dateOfDeath: Date?
    
    open var gender: Gender?
    
    open var addresses: [Address]?
    
    open var licences: [Licence]?
    
    open var contacts: [Contact]?
    
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
        familyName = unboxer.unbox(key: "familyName")

        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Person.dateTransformer)
        dateOfDeath = unboxer.unbox(key: "dateOfDeath", formatter: Person.dateTransformer)
     
        gender = unboxer.unbox(key: "gender")
        
        addresses = unboxer.unbox(key: "addresses")
        licences = unboxer.unbox(key: "licences")
        contacts = unboxer.unbox(key: "contacts")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
}
