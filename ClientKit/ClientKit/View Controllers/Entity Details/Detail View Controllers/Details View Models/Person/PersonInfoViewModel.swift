//
//  PersonInfoViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonInfoViewModel: EntityDetailsViewModelable {
    
    /// Specify the concrete type for sections
    public typealias DetailsType = PersonInfo
    
    public weak var delegate: EntityDetailsViewModelDelegate?
    
    // MARK: - Initialize
    
    public var person: Person? {
        didSet {
            guard let person = self.person else {
                self.sections = []
                return
            }
            
            var sections: [DetailsType] = [
                PersonInfo(type: .header, items: nil),
                PersonInfo(type: .details, items: [
                    DetailItem.status,
                    DetailItem.idn
                    ])
            ]
            
            if let licences = person.licences {
                licences.forEach {
                    sections.append(PersonInfo(type: .licence($0), items: LicenceItem.licenceItems(for: $0)))
                }
            }
            
            if let aliases = person.aliases, aliases.isEmpty == false {
                sections.append(PersonInfo(type: .aliases, items: aliases))
            }
            
            if let addresses = person.addresses, addresses.isEmpty == false {
                sections.append(PersonInfo(type: .addresses, items: addresses)) // TODO: Sort by date
            }
            
//            var contactDetails: [ContactDetailItem] = []
//                        if let emails = person.emails {
//                            emails.forEach {
//                                contactDetails.append(.email($0))
//                            }
//                        }
//            if let phones = person.phoneNumbers {
//                phones.forEach {
//                    contactDetails.append(.phone($0))
//                }
//            }
//            
//            if contactDetails.count > 0 {
//                sections.append(PersonInfo(type: .contact, items: contactDetails))
//            }
            
            self.sections = sections
        }
    }
    
    public var sections: [DetailsType] = [PersonInfo(type: .header, items: nil)]{
        didSet {
            delegate?.reloadData()
        }
    }
    
    // MARK: - Public methods
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        return sections[section].items?.count ?? 1
    }
    
    public func detailItem(at indexPath: IndexPath) -> Any? {
        return sections[ifExists: indexPath.section]?.items?[indexPath.item]
    }
    
    /// Header section
    public func header(for section: Int) -> String? {
        let section = item(at: section)!
        switch section.type {
        case .header:
            let lastUpdatedString: String
            if let lastUpdated = person?.lastUpdated {
                lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
            } else {
                lastUpdatedString = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return NSLocalizedString("LAST UPDATED: ", bundle: .mpolKit, comment: "") + lastUpdatedString
        default:
            return section.type.localizedTitle(withCount: section.items?.count)
        }
    }
    
    public func headerCellInfo() -> HeaderSectionCellInfo {
        let source        = person?.category
        let title         = person?.title
        let subtitle      = person?.detail1
        let description   = headerCellDescription()
        let buttonTitle   = headerCellAdditionalButtonTitle()
        let isPlaceholder = headerCellIsDescriptionPlaceholder()
        
        
        return HeaderSectionCellInfo(person: person,
                                     source: source,
                                     title:title,
                                     subtitle: subtitle,
                                     description: description,
                                     additionalDetailsButtonTitle: buttonTitle,
                                     isDescriptionPlaceholder: isPlaceholder)
    }
    
    public func cellInfo(for section: DetailsType, at indexPath: IndexPath) -> SectionCellInfo {
        var title   : String?
        var subtitle: String?
        var value   : String?
        var image   : UIImage?
        
        var isEditable          : Bool?
        var isProgressCell      : Bool?
        var progress            : Float?
        var isProgressViewHidden: Bool?
        
        let item = section.items![indexPath.item]
        
        switch section.type {
        case .details:
            let item = item as! DetailItem
            title = item.localizedTitle
            value = item.value(for: person!)
            image = nil
        case .addresses:
            let item = item as! Address
            
            if let date = item.reportDate {
                title = String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), item.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
            } else {
                title = String(format:NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""),  item.type ?? "Unknown")
            }
            
            value = item.formatted()
            image = AssetManager.shared.image(forKey: .location)
        case .contact:
            let item = item as! ContactDetailItem
            title = item.localizedTitle
            value = item.value?.ifNotEmpty() ?? "N/A"
            image = item.image
        case .aliases:
            let item = item as! Alias
            title = item.formattedName
            subtitle = item.formattedDOBAgeGender()
        case .licence(let licence):
            let item = item as! LicenceItem
            title  = item.localizedTitle
            value = item.value(for: licence)
            isProgressCell = (item == .validity)
            
            if let _ = isProgressCell {
                isProgressViewHidden = true
                isEditable = false
                
                if let startDate = licence.effectiveDate, let endDate = licence.expiryDate {
                    isProgressViewHidden = false
                    let timeIntervalBetween = endDate.timeIntervalSince(startDate)
                    let timeIntervalToNow   = startDate.timeIntervalSinceNow * -1.0
                    progress = Float(timeIntervalToNow / timeIntervalBetween)
                }
            }
        default:
            break
        }
        
        return SectionCellInfo(title: title,
                               subtitle: subtitle,
                               value: value,
                               image: image,
                               isEditable: isEditable,
                               isProgressCell: isProgressCell,
                               progress: progress,
                               isProgressViewHidden: isProgressViewHidden)
    }
    
    public var personDescriptions: [PersonDescription]? {
        return person?.descriptions
    }
    
    // Header content for collectionview calculates minimum content height
    public func headerInfoForMinimumContentHeight() -> HeaderInfoForMinimumContentHeight {
        let title = person?.summary ?? ""
        let subtitle = person?.summaryDetail1
        let description = person?.descriptions?.first?.formatted()
        let placeholder = NSLocalizedString("No description", bundle: .mpolKit, comment: "")
        let additionalDetails = person?.descriptions != nil && person!.descriptions!.count > 1 ? "X MORE DESCRIPTIONS" : nil
        let source = person?.source?.localizedBadgeTitle
        
        return HeaderInfoForMinimumContentHeight(title: title,
                                                 subtitle: subtitle,
                                                 description: description,
                                                 placeholder: placeholder,
                                                 additionalDetails: additionalDetails,
                                                 source: source)
    }
    
    // Content for collectionview calculates minimum content height
    public func itemInforForMinimumContentHeight(at indexPath: IndexPath) -> ItemInforForMinimumContentHeight {
        
        let section = self.item(at: indexPath.section)!
        
        var wantsSingleLineValue: Bool?
        var title: String?
        var value: String?
        var image: UIImage?
        
        let item = section.items![indexPath.item]
        
        switch section.type {
        case .aliases:
            let alias = item as! Alias
            title = alias.formattedName ?? ""
            value = alias.formattedDOBAgeGender()
            image = nil
        case .details:
            let item = item as! DetailItem
            title = item.localizedTitle
            value = item.value(for: person!)
            image = nil
            wantsSingleLineValue = false
        case .addresses:
            let item = item as! Address
            
            if let date = item.reportDate {
                title = String(format: NSLocalizedString("%@ Recorded as at %@", bundle: .mpolKit, comment: ""), item.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
            } else {
                title = String(format: NSLocalizedString("%@ Recorded date unknown", bundle: .mpolKit, comment: ""), item.type ?? "Unknown")
            }
            
            value = item.formatted()
            image = AssetManager.shared.image(forKey: .location)
            wantsSingleLineValue = false
        case .contact:
            let item = item as! ContactDetailItem
            title = item.localizedTitle
            value = item.value?.ifNotEmpty() ?? "N/A"
            image = item.image
            wantsSingleLineValue = true
        case .licence(let licence):
            let item = item as! LicenceItem
            
            title  = item.localizedTitle
            value = item.value(for: licence)
            image  = nil
            wantsSingleLineValue = true
        default:
            break
        }
        
        return ItemInforForMinimumContentHeight(title: title,
                                                value: value,
                                                image: image,
                                                wantsSingleLineValue: wantsSingleLineValue)
    }
    
    
    
    /// Calculate the filling columns for Licence section
    public func licenceItemFillingColumns(at indexPath: IndexPath) -> Int {
        let licenceItem = detailItem(at: indexPath)! as! LicenceItem
        return (licenceItem == .validity) ? 2 : 1
    }
    
    // MARK: Private methods
    
    private func headerCellFirstDescription() -> ([PersonDescription], PersonDescription)? {
        if let descriptions = person?.descriptions, let firstDescription = descriptions.first {
            return (descriptions, firstDescription)
        }
        return nil
    }
    
    private func headerCellDescription() -> String? {
        guard let (_, firstDescription) = headerCellFirstDescription() else {
            return NSLocalizedString("No description", bundle: .mpolKit, comment: "")
        }
        return firstDescription.formatted()
    }
    
    private func headerCellIsDescriptionPlaceholder() -> Bool {
        guard let (_, _) = headerCellFirstDescription() else { return true }
        return false
    }
    
    private func headerCellAdditionalButtonTitle() -> String? {
        guard let (descriptions, _) = headerCellFirstDescription(), descriptions.count > 1 else {
            return nil
        }
        let moreDescriptionsCount = descriptions.count - 1
        let buttonTitle = "\(moreDescriptionsCount) MORE DESCRIPTION\(moreDescriptionsCount > 1 ? "S" : "")"
        
        return buttonTitle
    }
    
    
    // MARK: Layout calculation models 
    public struct HeaderInfoForMinimumContentHeight {
        let title            : String?
        let subtitle         : String?
        let description      : String?
        let placeholder      : String?
        let additionalDetails: String?
        let source           : String?
    }
    
    public struct ItemInforForMinimumContentHeight {
        let title: String?
        let value: String?
        let image: UIImage?
        let wantsSingleLineValue: Bool?
    }
    
    // MARK: - Cell Models
    
    public struct HeaderSectionCellInfo {
        let person     : Person?
        let source     : String?
        let title      : String?
        let subtitle   : String?
        let description: String?
        
        let additionalDetailsButtonTitle: String?
        let isDescriptionPlaceholder    : Bool
    }
    
    public struct SectionCellInfo {
        let title     : String?
        let subtitle  : String?
        let value     : String?
        let image     : UIImage?
        let isEditable: Bool?
        
        let isProgressCell      : Bool?
        let progress            : Float?
        let isProgressViewHidden: Bool?
        
        var progressTintColor   : UIColor? {
            guard let progress = progress else {
                return nil
            }
            return progress > 1.0 ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
        }
    }
    
    // MARK: - Models for section and section detailed items
    
    public struct PersonInfo {
        var type: SectionType
        var items: [Any]?
    }
    
    public enum SectionType {
        case header
        case details
        case aliases
        case licence(Licence)
        case addresses
        case contact
        
        func localizedTitle(withCount count: Int? = nil) -> String {
            switch self {
            case .header:
                return NSLocalizedString("LAST UPDATED", bundle: .mpolKit, comment: "")
            case .details:
                return NSLocalizedString("DETAILS", bundle: .mpolKit, comment: "")
            case .aliases:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ALIAS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ALIASES", bundle: .mpolKit, comment: ""),
                                  count != nil ? String(describing: count!) : NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .licence(_):
                return NSLocalizedString("LICENCE", bundle: .mpolKit, comment: "")
            case .addresses:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ADDRESS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ADDRESSES", bundle: .mpolKit, comment: ""),
                                  count != nil ? String(describing: count!) : NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .contact:
                return NSLocalizedString("CONTACT DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    public enum DetailItem {
        case status
        case idn
        
        var localizedTitle: String {
            switch self {
            case .status:
                return NSLocalizedString("Last Known Status", bundle: .mpolKit, comment: "")
            case .idn:
                return NSLocalizedString("Identification Number", bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for person: Person) -> String? {
            switch self {
            case .idn:
                return person.id
            case .status:
                return person.dateOfDeath != nil ? "N/A" : "Alive"
            }
        }
    }
    
    public enum LicenceItem: Int {
        case number
        case state
        case country
        case status
        case validity
        
        static func licenceItems(for licence: Licence) -> [LicenceItem] {
            return [.number, .state, .country, .status, .validity]
        }
        
        var localizedTitle: String {
            switch self {
            case .number:        return NSLocalizedString("Licence number", bundle: .mpolKit, comment: "")
            case .state:         return NSLocalizedString("State",          bundle: .mpolKit, comment: "")
            case .country:       return NSLocalizedString("Country",        bundle: .mpolKit, comment: "")
            case .status:        return NSLocalizedString("Status",         bundle: .mpolKit, comment: "")
            case .validity:      return NSLocalizedString("Valid until",    bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for licence: Licence) -> String? {
            // TODO: Fill these details in
            switch self {
            case .number:
                return licence.number
            case .state:
                return licence.state
            case .country:
                return licence.country
            case .status:
                return licence.status
            case .validity:
                if let effectiveDate = licence.expiryDate {
                    return DateFormatter.mediumNumericDate.string(from: effectiveDate)
                } else {
                    return NSLocalizedString("Expiry date unknown", bundle: .mpolKit, comment: "")
                }
            }
        }
    }
    
    public enum ContactDetailItem {
        case email(Email)
        case phone(PhoneNumber)
        
        var localizedTitle: String {
            switch self {
            case .email(_): return NSLocalizedString("Email Address", bundle: .mpolKit, comment: "")
            case .phone(let phone): return NSLocalizedString(phone.formattedType(), bundle: .mpolKit, comment: "")
            }
        }
        
        var value: String? {
            switch self {
            case .email(_): return "john.citizen@gmail.com"
            case .phone(let phone): return phone.formattedNumber()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .email(_): return UIImage(named: "iconFormEmail", in: .mpolKit, compatibleWith: nil)
            case .phone(_): return AssetManager.shared.image(forKey: .audioCall)
            }
        }
    }
}

fileprivate extension Alias {
    
    func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            
            let dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
            
//            if let gender = sex?.localizedCapitalized {
//                dobString += " \(gender))"
//            } else {
//                dobString += ")"
//            }
            return dobString
//        } else if let gender = sex?.localizedCapitalized, gender.isEmpty == false {
//            return gender + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
        } else {
            return NSLocalizedString("DOB", bundle: .mpolKit, comment: "")
        }
    }
}
