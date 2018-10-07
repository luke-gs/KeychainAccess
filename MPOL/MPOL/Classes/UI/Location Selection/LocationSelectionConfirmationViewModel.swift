//
//  AddressViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class LocationSelectionConfirmationViewModel {
    
    public let fullAddress: String?
    public let coords: String?
    
    // details
    public var propertyNumber: String?
    public var streetNumber: String?
    public var streetName: String?
    public var postcode: String?
    public var remarks: String?
    
    // DropDown value
    public var streetType: AnyPickable?
    public var suburb: AnyPickable?
    public var state: AnyPickable?
    public var involvement: AnyPickable?
    
    // DropDown options
    public var streetTypeOptions: [AnyPickable]?
    public var suburbOptions: [AnyPickable]?
    public var stateOptions: [AnyPickable]?
    
    public var involvementOptions: [AnyPickable]?

    public let isEditable: Bool
    
    public init(fullAddress: String? = nil,
                coords: String? = nil,
                propertyNumber: String? = nil,
                streetNumber: String? = nil,
                streetName: String? = nil,
                streetType: AnyPickable? = nil,
                suburb: AnyPickable? = nil,
                state: AnyPickable? = nil,
                postcode: String? = nil,
                involvement: AnyPickable? = nil,
                streetTypeOptions: [AnyPickable]? = nil,
                suburbOptions: [AnyPickable]? = nil,
                stateOptions: [AnyPickable]? = nil,
                involvementOptions: [AnyPickable]? = nil,
                isEditable: Bool = false) {
        self.fullAddress = fullAddress
        self.coords = coords
        self.propertyNumber = propertyNumber
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.streetType = streetType
        self.suburb = suburb
        self.state = state
        self.postcode = postcode
        self.involvement = involvement
        self.streetTypeOptions = streetTypeOptions
        self.suburbOptions = suburbOptions
        self.stateOptions = stateOptions
        self.involvementOptions = involvementOptions
        self.isEditable = isEditable
    }

    public convenience init(locationSelection: LocationSelectionType, isEditable: Bool = false) {
        let coordinateText = "\(locationSelection.coordinate.latitude), \(locationSelection.coordinate.longitude)"

        self.init(fullAddress: locationSelection.displayText,
                  coords: coordinateText,
                  isEditable: isEditable)
    }
}
