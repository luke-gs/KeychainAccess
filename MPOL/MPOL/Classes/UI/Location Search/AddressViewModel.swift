//
//  AddressViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class AddressViewModel {
    
    public let fullAddress: String?
    public let coords: String?
    
    // details
    public var propertyNumber: String?
    public var streetNumber: String?
    public var streetName: String?
    public var streetType: AnyPickable?
    public var suburb: AnyPickable?
    public var state: AnyPickable?
    public var postcode: String?
    
    // DropDown options
    public var streetTypeOptions: [AnyPickable]
    public var suburbOptions: [AnyPickable]
    public var stateOptions: [AnyPickable]
    
    public var remarks: String?
    public var involvement: AnyPickable?
    public var involvementOptions: [AnyPickable]
    
    
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
                streetTypeOptions: [AnyPickable],
                suburbOptions: [AnyPickable],
                stateOptions: [AnyPickable],
                involvementOptions: [AnyPickable],
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
}
