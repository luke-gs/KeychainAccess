//
//  VehicleInfoViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehicleInfoViewModel: EntityDetailViewModelable {

    public typealias DetailsType = VehicleInfo
    
    public weak var delegate: EntityDetailViewModelDelegate?
    
    // MARK - Entity
    public var vehicle: Vehicle? {
        didSet {
            guard let _ = self.vehicle else {
                self.sections = []
                return
            }
            
            let sections: [DetailsType] = [
                VehicleInfo(type: .header, items: nil),
                VehicleInfo(type: .registration, items: [
                    RegistrationItem.status,
                    RegistrationItem.validity,
                    RegistrationItem.manufactured,
                    RegistrationItem.make,
                    RegistrationItem.model,
                    RegistrationItem.vin,
                    RegistrationItem.engine,
                    RegistrationItem.fuel,
                    RegistrationItem.transmission,
                    RegistrationItem.color1,
                    RegistrationItem.color2,
                    RegistrationItem.weight,
                    RegistrationItem.tare,
                    RegistrationItem.seating])
            ]
            
            self.sections = sections
        }
    }
    
    public var sections: [DetailsType] = []{
        didSet {
            delegate?.reloadData()
        }
    }

    public lazy var collapsedSections: Set<Int> = []
    
    // MARK: - Public methods
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(for section: Int) -> Int {
        if collapsedSections.contains(section) {
            return 0
        }
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
            if let lastUpdated = vehicle?.lastUpdated {
                lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
            } else {
                lastUpdatedString = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return NSLocalizedString("LAST UPDATED: ", bundle: .mpolKit, comment: "") + lastUpdatedString
        default:
            return section.type.localizedTitle
        }
    }
    
    public func headerCellInfo() -> HeaderSectionCellInfo {
        let source        = vehicle?.category
        let title         = vehicle?.title
        let subtitle      = formattedSubtitle()
        let description   = vehicle?.vehicleDescription ?? "No Description"
        
        
        return HeaderSectionCellInfo(vehicle: vehicle,
                                     source: source,
                                     title:title,
                                     subtitle: subtitle,
                                     description: description)
    }
    
    public func formattedSubtitle() -> String? {
        return [vehicle?.detail1, vehicle?.variant].flatMap({$0}).joined(separator: " ")
    }
    
    public func cellInfo(for section: DetailsType, at indexPath: IndexPath) -> SectionCellInfo {
        var title   : String?
        var value   : String?
        var isEditable          : Bool?
        var isProgressCell      : Bool?
        var progress            : Float?
        var isProgressViewHidden: Bool?
        var multiLineSubtitle : Bool = false
        
        let item = section.items![indexPath.item]

        switch section.type {
        case .registration:
            let item = item as! RegistrationItem
            title    = item.localizedTitle
            value = item.value(from: vehicle!)
            isProgressCell = (item == .validity)
            multiLineSubtitle = false
            
            if let _ = isProgressCell {
                isProgressViewHidden = true
                isEditable = false
                
//                if let startDate = vehicle!.registrationEffectiveDate, let endDate = vehicle!.registrationExpiryDate {
//                    isProgressViewHidden = false
//                    let timeIntervalBetween = endDate.timeIntervalSince(startDate)
//                    let timeIntervalToNow   = startDate.timeIntervalSinceNow * -1.0
//                    progress = Float(timeIntervalToNow / timeIntervalBetween)
//                }
                
                if let expiryDate = vehicle!.registrationExpiryDate {
                    isProgressViewHidden = false
                    progress = Float((Date().timeIntervalSince1970 / expiryDate.timeIntervalSince1970))
                }
            }
        default:
            break
        }
        
        return SectionCellInfo(title: title,
                               value: value,
                               isEditable: isEditable,
                               isProgressCell: isProgressCell,
                               progress: progress,
                               isProgressViewHidden: isProgressViewHidden,
                               multiLineSubtitle: multiLineSubtitle)
    }
    
    /// Calculate the filling columns for Licence section
    public func regoItemFillingColumns(at indexPath: IndexPath) -> Int {
        let regoItem = detailItem(at: indexPath)! as! RegistrationItem
        return (regoItem == .validity) ? 2 : 1
    }
    
    
    public func registrationItem(at index: Int) -> RegistrationItem? {
        return RegistrationItem(rawValue: index)
    }
    
    public func owerItem(at index: Int) -> OwnerItem? {
        return OwnerItem(rawValue: index)
    }
    
    // MARK: Private methods
    
    // MARK: Section Cell
    
    public struct HeaderSectionCellInfo {
        let vehicle     : Vehicle?
        let source     : String?
        let title      : String?
        let subtitle   : String?
        let description: String?
    }
    
    public struct SectionCellInfo {
        let title     : String?
        var value   : String?
        let isEditable: Bool?
        
        let isProgressCell      : Bool?
        let progress            : Float?
        let isProgressViewHidden: Bool?
        let multiLineSubtitle   : Bool

        var progressTintColor   : UIColor? {
            guard let progress = progress else {
                return nil
            }
            return progress > 1.0 ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
        }
    }
    
    // MARK: - Section & Item Enum
        
    public struct VehicleInfo {
        var type: SectionType
        var items: [Any]?
    }
    
    public enum SectionType {
        case header
        case registration
        
        var localizedTitle: String {
            switch self {
            case .header:       return NSLocalizedString("LAST UPDATED",         bundle: .mpolKit, comment: "")
            case .registration: return NSLocalizedString("REGISTRATION DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    public enum RegistrationItem: Int {
        case status
        case validity
        
        case manufactured
        case make
        case model
        
        case vin
        case engine
        case fuel
        
        case transmission
        case color1
        case color2
        
        case weight
        case tare
        case seating
        
        static func RegistrationItems() -> [RegistrationItem] {
            return [.status,
                    .validity,
                    .manufactured,
                    .make,
                    .model,
                    .vin,
                    .engine,
                    .fuel,
                    .transmission,
                    .color1,
                    .color2,
                    .weight,
                    .tare,
                    .seating]
        }
        
        var localizedTitle: String {
            switch self {
            case .status:       return NSLocalizedString("Status",             bundle: .mpolKit, comment: "")
            case .validity:     return NSLocalizedString("Valid until",        bundle: .mpolKit, comment: "")
            case .manufactured: return NSLocalizedString("Manufactured in",    bundle: .mpolKit, comment: "")
            case .make:         return NSLocalizedString("Make",               bundle: .mpolKit, comment: "")
            case .model:        return NSLocalizedString("Model",              bundle: .mpolKit, comment: "")
            case .vin:          return NSLocalizedString("VIN/Chassis Number", bundle: .mpolKit, comment: "")
            case .engine:       return NSLocalizedString("Engine Number",      bundle: .mpolKit, comment: "")
            case .fuel:         return NSLocalizedString("Fuel Type",          bundle: .mpolKit, comment: "")
            case .transmission: return NSLocalizedString("Transmission",       bundle: .mpolKit, comment: "")
            case .color1:       return NSLocalizedString("Primary Colour",     bundle: .mpolKit, comment: "")
            case .color2:       return NSLocalizedString("Secondary Colour",   bundle: .mpolKit, comment: "")
            case .weight:       return NSLocalizedString("Gross Vehicle Mass", bundle: .mpolKit, comment: "")
            case .tare:         return NSLocalizedString("TARE",               bundle: .mpolKit, comment: "")
            case .seating:      return NSLocalizedString("Seating Capacity",   bundle: .mpolKit, comment: "")
            }
        }
        
        func value(from vehicle: Vehicle?) -> String? {
            // TODO: Fill these details in
            switch self {
            case .status:       return vehicle?.registrationStatus ?? "-"
            case .validity:
                if let effectiveDate = vehicle?.registrationExpiryDate {
                    return DateFormatter.mediumNumericDate.string(from: effectiveDate)
                }
                return "-"
            case .manufactured: return vehicle?.year ?? "-"
            case .make:         return vehicle?.make ?? "-"
            case .model:        return vehicle?.model ?? "-"
            case .vin:          return vehicle?.vin ?? "-"
            case .engine:       return vehicle?.engineNumber ?? "-"
            case .fuel:         return "-"
            case .transmission: return vehicle?.transmission ?? "-"
            case .color1:       return vehicle?.primaryColor ?? "-"
            case .color2:       return vehicle?.secondaryColor ?? "-"
            case .weight:
                guard let weight = vehicle?.weight, weight > 0 else { return "-" }
                return String(describing: weight) + " kg"
            case .tare:         return "-"
            case .seating:
                guard let seatCapacity = vehicle?.seatingCapacity, seatCapacity > 0 else { return "-" }
                return String(describing: seatCapacity)

            }
        }
    }
    
    public enum OwnerItem: Int {
        case name
        case dob
        case gender
        case address
        
        static let count: Int = 4
        
        var localizedTitle: String {
            switch self {
            case .name:    return NSLocalizedString("Name",          bundle: .mpolKit, comment: "")
            case .dob:     return NSLocalizedString("Date of Birth", bundle: .mpolKit, comment: "")
            case .gender:  return NSLocalizedString("Gender",        bundle: .mpolKit, comment: "")
            case .address: return NSLocalizedString("Address",       bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for vehicle: Any?) -> String {
            // TODO: Fill these details in
            switch self {
            case .name:    return "Citizen, John R"
            case .dob:     return "08/05/1987 (29)"
            case .gender:  return "Male"
            case .address: return "8 Catherine Street, Southbank VIC 3006"
            }
        }
        
        var wantsMultiLineDetail: Bool {
            switch self {
            case .address: return true
            default:       return false
            }
        }
    }
}
