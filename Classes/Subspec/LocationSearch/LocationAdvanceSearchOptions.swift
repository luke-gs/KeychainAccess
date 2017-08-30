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
    case VIC, NSW, NT, AC, TAS, QLD, WA, SA

    public var title: String? { return self.rawValue }
    public var subtitle: String? { return "" }

    public static let all: [StateType] = [
        .VIC, .NSW, .NT, .AC, .TAS, .QLD, .WA, SA
    ]
}

open class LocationAdvanceSearchOptions: SearchOptions {
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
    
    open func reset() {
        unit = nil
        streetNumberStart = nil
        streetNumberEnd = nil
        streetName = nil
        streetType = .street
        suburb = nil
        postcode = nil
        state = .VIC
    }
    
    open func populate(with options: [Int: String]) {
        for index in 0..<LocationAdvanceItem.count {
            switch LocationAdvanceItem(rawValue: index)! {
            case .unit:
                unit = options[index]
            case .streetNumberStart:
                streetNumberStart = options[index]
            case .streetNumberEnd:
                streetNumberEnd = options[index]
            case .streetName:
                streetName = options[index]
            case .streetType:
                if let option = options[index] {
                    streetType = StreetType(rawValue: option) ?? .street
                } else {
                    streetType = .street
                }
            case .suburb:
                suburb = options[index]
            case .postcode:
                postcode = options[index]
            case .state:
                if let option = options[index] {
                    state = StateType(rawValue: option) ?? .VIC
                } else {
                    state = .VIC
                }
            }
        }
    }
    
    open var textRepresentation: String? {
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
