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
    
    public enum Gender: Int, CustomStringConvertible, UnboxableEnum, Pickable {
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
        
        public var title: String? { return description }
        
        public var subtitle: String? { return nil }
        
        public static let allCases: [Gender] = [.female, .male, .other]
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
    open var initials: String?
    
    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""
        
        let middleNames = self.middleNames?.filter { $0.isEmpty == false }
        
        if let surname = self.surname?.ifNotEmpty() {
            formattedName = surname
            
            if givenName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.givenName?.ifNotEmpty() {
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
    
    open var interventionOrders: [InterventionOrder]?
    open var bailOrders: [BailOrder]?
    open var fieldContacts: [FieldContact]?
    open var whereabouts: [Whereabouts]?
    open var missingPersonReports: [MissingPersonReport]?
    open var familyIncidents: [FamilyIncident]?
    
    open var criminalHistory: [CriminalHistory]?
    
    open var thumbnail: UIImage?
    private lazy var initialThumbnail: UIImage = { [unowned self] in
        if let initials = self.initials?.ifNotEmpty() {            
            return UIImage.thumbnail(withInitials: initials)
        }
        return UIImage()
    }()
    
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
        
        try super.init(unboxer: unboxer)

        givenName = unboxer.unbox(key: "givenName")
        surname = unboxer.unbox(key: "surname")
        middleNames = unboxer.unbox(key: "middleNames")
        fullName    = unboxer.unbox(key: "fullName")

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
        
        interventionOrders = unboxer.unbox(key: "interventionOrders")
        bailOrders = unboxer.unbox(key: "bailOrders")
        fieldContacts = unboxer.unbox(key: "fieldContacts")
        whereabouts = unboxer.unbox(key: "whereabouts")
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
    }
    
    open override func encode(with aCoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    // MARK: - Model Versionable
    override open class var modelVersion: Int {
        return 0
    }
    
    
    
    // MARK: - Display
    
    // TEMPORARY
    open override func thumbnailImage(ofSize size: EntityThumbnailView.ThumbnailSize) -> (UIImage, UIViewContentMode)? {
        if let thumbnail = self.thumbnail {
            return (thumbnail, .scaleAspectFill)
        }
        if initials?.isEmpty ?? true == false {
            return (initialThumbnail, .scaleAspectFill)
        }
        return nil
    }
    
    open override var summaryDetail1: String? {
        return formattedDOBAgeGender()
    }
    
    open override var summaryDetail2: String? {
        return formattedSuburbStatePostcode()
    }
    
    private func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            
            var dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
            
            if let gender = gender {
                dobString += " \(gender.description))"
            } else {
                dobString += ")"
            }
            return dobString
        } else if let gender = gender {
            return gender.description + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", bundle: .mpolKit, comment: "")
        }
    }
    
    private func formattedSuburbStatePostcode() -> String? {
        if let address = addresses?.first {
            
            let components = [address.suburb, address.state, address.postcode].flatMap({$0})
            if components.isEmpty == false {
                return components.joined(separator: " ")
            }
        }
        
        return nil
    }
    
}
