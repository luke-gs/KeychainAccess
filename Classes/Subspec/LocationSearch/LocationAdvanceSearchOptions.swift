//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation


public enum LocationAdvanceItem: Int {
    case unit
    case streetNumberStart
    case streetNumberEnd
    case streetName
    case streetType
    case suburb
    case postcode
    case state

    public static let count = 8
    public static let titles: [LocationAdvanceItem: String] = [
        .unit:              "Unit / House / Apt No.",
        .streetNumberStart: "Street No. Start",
        .streetNumberEnd:   "Street No. End",
        .streetName:        "Street Name",
        .streetType:        "Street Type",
        .suburb:            "Suburb",
        .postcode:          "Postcode",
        .state:             "State"
    ]

    public var title: String { return LocationAdvanceItem.titles[self]! }
}

public enum StreetType: String, Pickable {
    case street     = "Street"
    case road       = "Road"
    case avenue     = "Avenue"
    case boulevard  = "Boulevard"
    case crescent   = "Crescent"
    case drive      = "Drive"
    case lane       = "Lane"
    case place      = "Place"
    case terrace    = "Terrace"
    case way        = "Way"

    public var title: String? { return self.rawValue }
    public var subtitle: String? { return nil }

    public static let all: [StreetType] = [
        .street, .road, .drive, .place, .crescent, .lane, .avenue, .boulevard, .way, .terrace
    ]
}

public enum StateType: String, Pickable {
    case VIC = "Victoria"
    case NSW = "New South Wales"
    case NT  = "Northern Territory"
    case ACT = "Australian Capital Territory"
    case TAS = "Tasmania"
    case QLD = "Queensland"
    case WA  = "Westhern Australia"
    case SA  = "South Australia"

    public var title: String? { return self.rawValue }
    public var subtitle: String? { return "" }

    public static let all: [StateType] = [
        .VIC, .NSW, .NT, .ACT, .TAS, .QLD, .WA, SA
    ]
}


open class LocationAdvanceSearchOptions: LocationAdvanceOptions {
    public let cancelTitle: String = NSLocalizedString("GO BACK TO SIMPLE SEARCH", comment: "Location Search - Back to simple search")
    
    open var unit:               String?
    open var streetNumberStart:  String?
    open var streetNumberEnd:    String?
    open var streetName:         String?
    open var streetType:         StreetType? = .street
    open var suburb:             String?
    open var postcode:           String?
    open var state:              StateType?  = .VIC

    open let headerText: String? = NSLocalizedString("EDIT ADDRESS", comment: "Location Search - Edit address")

    open var numberOfOptions: Int {
        return LocationAdvanceItem.count
    }

    open func title(at index: Int) -> String {
        return LocationAdvanceItem(rawValue: index)!.title
    }

    open func value(at index: Int) -> String? {
        switch LocationAdvanceItem(rawValue: index)! {
        case .unit:                 return unit
        case .streetNumberStart:    return streetNumberStart
        case .streetNumberEnd:      return streetNumberEnd
        case .streetName:           return streetName
        case .streetType:           return streetType?.rawValue
        case .suburb:               return suburb
        case .postcode:             return postcode
        case .state:                return state?.rawValue
        }
    }

    open func defaultValue(at index: Int) -> String {
        switch LocationAdvanceItem(rawValue: index)! {
        case .unit:                 return "eg. 317"
        case .streetNumberStart:    return "eg. 188"
        case .streetNumberEnd:      return "eg. 200"
        case .streetName:           return "eg. Wellintong"
        case .streetType:           return "Select"
        case .suburb:               return "eg. Collingwood"
        case .postcode:             return "eg. 3066"
        case .state:                return "Select"
        }
    }

    open func type(at index: Int) -> SearchOptionType {
        let item = LocationAdvanceItem(rawValue: index)!
        switch item {
        case .unit, .streetNumberStart, .streetNumberEnd, .postcode:
            return .text(configure: {textField in
                textField.keyboardType = .numbersAndPunctuation
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            })
        case .streetName, .suburb:
            return .text(configure: {textField in
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .yes
                textField.autocapitalizationType = .words
            })
        case .streetType, .state:
            return .picker
        }
    }
    
    open func errorMessage(at index: Int) -> String? {
        let item = LocationAdvanceItem(rawValue: index)!
        switch item {
        case .unit:
            let count = unit?.characters.count ?? 0
            return count > 5 ? "This should be less than 5 characters long." : nil
        default: break
        }
        return nil
    }
    
    open func pickerController(forFilterAt index: Int, updateHandler: @escaping () -> ()) -> UIViewController? {
        guard let item = LocationAdvanceItem(rawValue: index) else { return nil }
        
        // Handle advance options
        switch item {
        case .streetType:
            let types = StreetType.all
            
            let picker = PickerTableViewController(style: .plain, items: types)
            picker.selectedIndexes = types.indexes { $0 == self.streetType }
            picker.selectionUpdateHandler = { [weak self] (picker, selectedIndexes) in
                guard let selectedTypeIndex = selectedIndexes.first else { return }
                self?.streetType = types[selectedTypeIndex]
                
                updateHandler()
                picker.dismiss(animated: true, completion: nil)
            }
            picker.title = item.title
            return PopoverNavigationController(rootViewController: picker)
        case .state:
            let types = StateType.all
            
            let picker = PickerTableViewController(style: .plain, items: types)
            picker.selectedIndexes = types.indexes { $0 == self.state }
            picker.selectionUpdateHandler = { [weak self] (picker, selectedIndexes) in
                guard let selectedTypeIndex = selectedIndexes.first else { return }
                self?.state = types[selectedTypeIndex]
                
                updateHandler()
                picker.dismiss(animated: true, completion: nil)
            }
            picker.title = item.title
            return PopoverNavigationController(rootViewController: picker)
        default:
            return nil
        }
    }
    
    open func populate(withOptions options: [Int: String]?, reset: Bool) {
        if !reset {
            options?.forEach({ update(index: $0.key, withOption: $0.value) } )
        } else {
            for index in 0..<LocationAdvanceItem.count {
                let option = options?[index]
                update(index: index, withOption: option)
            }
        }
    }
    
    private func update(index: Int, withOption option: String?) {
        guard let item = LocationAdvanceItem(rawValue: index) else { return }
        switch item {
        case .unit: unit = option
        case .streetNumberStart: streetNumberStart = option
        case .streetNumberEnd: streetNumberEnd = option
        case .streetName: streetName = option
        case .streetType:
            if let option = option {
                streetType = StreetType(rawValue: option) ?? .street
            } else {
                streetType = .street
            }
        case .suburb: suburb = option
        case .postcode: postcode = option
        case .state:
            if let option = option {
                state = StateType(rawValue: option) ?? .VIC
            } else {
                state = .VIC
            }
        }
    }
    
    open func populate(withLocation location: LookupAddress) {
        self.unit = location.unitNumber
        self.streetNumberStart = location.streetNumberFirst
        self.streetName = location.streetName
        self.streetType = location.streetType != nil ? StreetType(rawValue: location.streetType!.capitalized) : nil
        self.suburb = location.suburb
        self.postcode = location.postalCode
        self.state = location.state != nil ? StateType(rawValue: location.state!.capitalized) : nil
    }
    
    open func textRepresentation() -> String? {
        var components = [String]()
        
        if let value = unit {
            components.append(value)
        }
        
        var streetNumberComponents = [String]()
        if let value = streetNumberStart {
            streetNumberComponents.append(value)
        }
        
        if let value = streetNumberEnd {
            streetNumberComponents.append(value)
        }
        
        var streetComponents = [String]()
        
        let streetNumberText = streetNumberComponents.joined(separator: " - ")
        if !streetNumberText.isEmpty {
            streetComponents.append(streetNumberText)
        }
        
        if let value = streetName {
            streetComponents.append(value)
        }
        
        if let value = streetType?.title {
            streetComponents.append(value)
        }
        
        let streetText = streetComponents.joined(separator: " ")
        if !streetText.isEmpty {
            components.append(streetText)
        }
        
        var regionComponents = [String]()
        if let value = suburb {
            regionComponents.append(value)
        }
        
        if let value = state?.title {
            regionComponents.append(value)
        }
        
        if let value = postcode {
            regionComponents.append(value)
        }
        
        let regionText = regionComponents.joined(separator: " ")
        if !regionText.isEmpty {
            components.append(regionText)
        }
        
        return components.joined(separator: ", ")
    }
}
