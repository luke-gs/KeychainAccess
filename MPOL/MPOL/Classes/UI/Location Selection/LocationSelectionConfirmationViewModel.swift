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
    public let coordinateText: String?
    
    // details
    public var propertyNumber: String? = nil
    public var streetNumber: String? = nil
    public var streetName: String? = nil
    public var postcode: String? = nil
    public var remarks: String? = nil
    
    // DropDown value
    public var streetType: AnyPickable? = nil
    public var suburb: AnyPickable? = nil
    public var state: AnyPickable? = nil

    // The location type, workflow specific
    public var type: AnyPickable? = nil
    public var typeTitle: String? = nil
    public var typeOptions: [AnyPickable]? = nil

    // DropDown options
    public var streetTypeOptions: [AnyPickable]? = nil
    public var suburbOptions: [AnyPickable]? = nil
    public var stateOptions: [AnyPickable]? = nil

    // Whether the address fields are user editable
    public var isEditable: Bool
    
    public init(locationSelection: LocationSelectionType, isEditable: Bool = false) {
        let coordinateText = "\(locationSelection.coordinate.latitude), \(locationSelection.coordinate.longitude)"

        self.fullAddress = locationSelection.displayText
        self.coordinateText = coordinateText
        self.isEditable = isEditable

        if let locationSelection = locationSelection as? LocationSelectionCore {
            if let placemark = locationSelection.placemark {
                self.streetNumber = placemark.subThoroughfare
                self.streetName = placemark.thoroughfare
                self.postcode = placemark.postalCode
                // TODO: set picker items from text strings
                // self.streetType = streetType
                // self.suburb = placemark.subLocality
                // self.state = placemark.region
            }

            if let searchResult = locationSelection.searchResult {
                self.propertyNumber = searchResult.unitNumber
                self.streetNumber = searchResult.streetNumber
                self.streetName = searchResult.streetName
                self.postcode = searchResult.postalCode
            }
        }
    }
}

fileprivate extension LookupAddress {
    var streetNumber: String? {
        var components: [String] = []
        if let streetNumberFirst = streetNumberFirst, streetNumberFirst.isEmpty == false {
            components.append(streetNumberFirst)
        }

        if let streetNumberEnd = streetNumberLast, streetNumberEnd.isEmpty == false {
            components.append(streetNumberEnd)
        }
        return components.joined(separator: "-")
    }
}
