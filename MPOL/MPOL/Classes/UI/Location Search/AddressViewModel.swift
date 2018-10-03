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
    public var streetType: String?
    public var suburb: String?
    public var state: String?
    public var postcode: String?
    
    // user input
    public var remarks: String?
    public var involvement: AnyPickable?
    
    
    public let isEditable: Bool
    
    public init(fullAddress: String? = nil,
                coords: String? = nil,
                propertyNumber: String? = nil,
                streetNumber: String? = nil,
                streetName: String? = nil,
                streetType: String? = nil,
                suburb: String? = nil,
                state: String? = nil,
                postcode: String? = nil,
                involvement: AnyPickable? = nil,
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
        self.isEditable = isEditable
    }
    
}
