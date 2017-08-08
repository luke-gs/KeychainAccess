//
//  VehicleInfoViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehicleInfoViewModel {
    
    // MARK - Entity
    public var vehicle: Vehicle?
    
    // Public methods
    public func numberOfItemsInSection(_ section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:       return 1
        case .registration: return RegistrationItem.count
        case .owner:        return OwnerItem.count
        }
    }
    
    public func numberOfSections() -> Int{
        return Section.count
    }
    
    public func section(at index: Int) -> Section? {
        return Section(rawValue: index)
    }
    
    /// Custom header text for each section
    public func headerText(for section: Int) -> String? {
        
        let type = Section(rawValue: section)!
        
        if type == .header {
            let lastUpdatedString: String
            if let lastUpdated = vehicle?.lastUpdated {
                lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
            } else {
                lastUpdatedString = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return NSLocalizedString("LAST UPDATED: ", bundle: .mpolKit, comment: "") + lastUpdatedString
        }
        return self.section(at: section)?.localizedTitle
    }
    
    public func cellInfo(for section: Section, at indexPath: IndexPath) -> CellInfo {
        var title             : String?
        var subtitle          : String?
        var multiLineSubtitle : Bool = false
        
        switch section {
        case .registration:
            let regoItem = RegistrationItem(rawValue: indexPath.item)!
            title    = regoItem.localizedTitle
            subtitle = regoItem.value(from: nil)
            multiLineSubtitle = false
        case .owner:
            let ownerItem = OwnerItem(rawValue: indexPath.item)!
            title    = ownerItem.localizedTitle
            subtitle = ownerItem.value(for: nil)
            multiLineSubtitle = ownerItem.wantsMultiLineDetail
        default:
            break
        }
        
        return CellInfo(title: title, subtitle: subtitle, multiLineSubtitle: multiLineSubtitle)
    }
    
    public func registrationItem(at index: Int) -> RegistrationItem? {
        return RegistrationItem(rawValue: index)
    }
    
    public func owerItem(at index: Int) -> OwnerItem? {
        return OwnerItem(rawValue: index)
    }
    
    // MARK: Private methods
    
    // MARK: Section Cell
    public struct CellInfo {
        let title             : String?
        let subtitle          : String?
        let multiLineSubtitle : Bool
    }
    
    // MARK: - Section & Item Enum
    
    public enum Section: Int {
        case header
        case registration
        case owner
        
        static let count = 3
        
        var localizedTitle: String {
            switch self {
            case .header:       return NSLocalizedString("LAST UPDATED",         bundle: .mpolKit, comment: "")
            case .registration: return NSLocalizedString("REGISTRATION DETAILS", bundle: .mpolKit, comment: "")
            case .owner:        return NSLocalizedString("REGISTERED OWNER",     bundle: .mpolKit, comment: "")
            }
        }
    }
    
    public enum RegistrationItem: Int {
        case make
        case model
        case vin
        case manufactured
        case transmission
        case color1
        case color2
        case engine
        case seating
        case weight
        
        static let count: Int = 10
        
        var localizedTitle: String {
            switch self {
            case .make:         return NSLocalizedString("Make",               bundle: .mpolKit, comment: "")
            case .model:        return NSLocalizedString("Model",              bundle: .mpolKit, comment: "")
            case .vin:          return NSLocalizedString("VIN/Chassis Number", bundle: .mpolKit, comment: "")
            case .manufactured: return NSLocalizedString("Manufactured in",    bundle: .mpolKit, comment: "")
            case .transmission: return NSLocalizedString("Transmission",       bundle: .mpolKit, comment: "")
            case .color1:       return NSLocalizedString("Colour 1",           bundle: .mpolKit, comment: "")
            case .color2:       return NSLocalizedString("Colour 2",           bundle: .mpolKit, comment: "")
            case .engine:       return NSLocalizedString("Engine",             bundle: .mpolKit, comment: "")
            case .seating:      return NSLocalizedString("Seating",            bundle: .mpolKit, comment: "")
            case .weight:       return NSLocalizedString("Curb weight",        bundle: .mpolKit, comment: "")
            }
        }
        
        func value(from vehicle: Any?) -> String {
            // TODO: Fill these details in
            switch self {
            case .make:         return "Tesla"
            case .model:        return "Model S P100D"
            case .vin:          return "1FUJA6CG47LY64774"
            case .manufactured: return "2020"
            case .transmission: return "Automatic"
            case .color1:       return "Black"
            case .color2:       return "Silver"
            case .engine:       return "Electric"
            case .seating:      return "2 + 3"
            case .weight:       return "2,239 kg"
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
