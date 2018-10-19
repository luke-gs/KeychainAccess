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
    public var propertyNumber: String?
    public var streetNumber: String?
    public var streetName: String?
    public var postcode: String?
    public var remarks: String?

    // DropDown value
    public var streetType: AnyPickable?
    public var suburb: AnyPickable?
    public var state: AnyPickable?

    // The location type, workflow specific
    public var type: AnyPickable?
    public var typeTitle: String?
    public var typeOptions: [AnyPickable]?

    // DropDown options
    public var streetTypeOptions: [AnyPickable]?
    public var suburbOptions: [AnyPickable]?
    public var stateOptions: [AnyPickable]?

    // Whether the address fields are user editable
    public var isEditable: Bool = false

    // Whether address components are enforced
    public var requiredFields: Bool = false

    public init(locationSelection: LocationSelectionType) {
        let coordinateText = "\(locationSelection.coordinate.latitude), \(locationSelection.coordinate.longitude)"

        self.fullAddress = locationSelection.displayText
        self.coordinateText = coordinateText

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
