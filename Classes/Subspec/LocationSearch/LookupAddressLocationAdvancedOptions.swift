//
// Created by KGWH78 on 22/8/17.
// Copyright (c) 2017 Gridstone. All rights reserved.
//

import Foundation


public enum LocationAdvanceItem: Int {
    case unit
    case streetNumber
    case streetName
    case streetType
    case suburb
    case postcode
    case state

    public static let count = 7
    public static let titles: [LocationAdvanceItem: String] = [
        .unit:         "Unit / House / Apt No.",
        .streetNumber: "Street No. / Range",
        .streetName:   "Street Name",
        .streetType:   "Street Type",
        .suburb:       "Suburb",
        .state:        "State",
        .postcode:     "Postcode"
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
    case WA  = "Western Australia"
    case SA  = "South Australia"

    public var title: String? { return self.rawValue }
    public var subtitle: String? { return "" }

    public static let all: [StateType] = [
        .VIC, .NSW, .NT, .ACT, .TAS, .QLD, .WA, SA
    ]
}


open class LookupAddressLocationAdvancedOptions: LocationAdvanceOptions {
    
    public typealias Location = LookupAddress
    
    public let title: String = NSLocalizedString("Advanced Search", comment: "")
    
    public let cancelTitle: String = NSLocalizedString("BACK TO SIMPLE SEARCH", comment: "Location Search - Back to simple search")
    
    open var unit:               String?
    open var streetNumber:       String?
    open var streetName:         String?
    open var streetType:         StreetType? = .street
    open var suburb:             String?
    open var postcode:           String?
    open var state:              StateType?  = .VIC

    open let headerText: String? = NSLocalizedString("EDIT ADDRESS", comment: "Location Search - Edit address")

    public let validator: LookupAddressValidator?
    
    public init(validator: LookupAddressValidator? = nil) {
        self.validator = validator
    }
    
    open var numberOfOptions: Int {
        return LocationAdvanceItem.count
    }

    open func title(at index: Int) -> String {
        return LocationAdvanceItem(rawValue: index)!.title
    }

    open func value(at index: Int) -> String? {
        switch LocationAdvanceItem(rawValue: index)! {
        case .unit:                 return unit
        case .streetNumber:         return streetNumber
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
        case .streetNumber:         return "eg. 188-200"
        case .streetName:           return "eg. Wellington"
        case .streetType:           return "Select"
        case .suburb:               return "eg. Collingwood"
        case .postcode:             return "eg. 3066"
        case .state:                return "Select"
        }
    }

    open func type(at index: Int) -> SearchOptionType {
        let item = LocationAdvanceItem(rawValue: index)!
        switch item {
        case .unit, .streetNumber, .postcode:
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
        return self.validator?.validate(item: item, value: value(at: index))
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
        case .streetNumber: streetNumber = option
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
        
        var components = [String]()
        if let streetNumberFirst = location.streetNumberFirst, streetNumberFirst.isEmpty == false {
            components.append(streetNumberFirst)
        }
        
        if let streetNumberEnd = location.streetNumberLast, streetNumberEnd.isEmpty == false {
            components.append(streetNumberEnd)
        }
        
        self.unit = location.unitNumber
        self.streetNumber = components.joined(separator: "-")
        self.streetName = location.streetName
        self.streetType = location.streetType != nil ? StreetType(rawValue: location.streetType!.capitalized) : nil
        self.suburb = location.suburb
        self.postcode = location.postalCode
        self.state = location.state != nil ? StateType(rawValue: location.state!.capitalized) : nil
    }
    
    open func textRepresentation() -> String? {
        var components = [String]()
        
        if let value = unit, value.isEmpty == false {
            components.append(value)
        }
        
        var streetComponents = [String]()
        if let value = streetNumber, value.isEmpty == false {
            streetComponents.append(value)
        }
        
        if let value = streetName, value.isEmpty == false {
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
        if let value = suburb, value.isEmpty == false {
            regionComponents.append(value)
        }
        
        if let value = state?.title {
            regionComponents.append(value)
        }
        
        if let value = postcode, value.isEmpty == false {
            regionComponents.append(value)
        }
        
        let regionText = regionComponents.joined(separator: " ")
        if !regionText.isEmpty {
            components.append(regionText)
        }
        
        return components.joined(separator: ", ")
    }
    
    open func locationParameters() -> Parameterisable {
        var parameters = LookupAddressAdvanceParameters()

        var streetNumberStart: String?
        var streetNumberEnd: String?
        
        if var components = streetNumber?.components(separatedBy: "-"), components.count > 0 {
            streetNumberStart = components.removeFirst()
            
            if components.count > 0 {
                streetNumberEnd = components.removeFirst()
            }
        }
        
        parameters.flatNumber = unit
        parameters.streetNumberStart = streetNumberStart
        parameters.streetNumberEnd = streetNumberEnd
        parameters.streetName = streetName
        parameters.streetType = streetType?.rawValue
        parameters.suburb = suburb
        parameters.state = state?.rawValue
        parameters.postalCode = postcode
        
        return parameters
    }
    
}
