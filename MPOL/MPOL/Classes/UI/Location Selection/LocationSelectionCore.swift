//
//  LocationSelectionCore.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit
import PublicSafetyKit
import Contacts
import Unbox

/// Demo app implementation for a location selection
public class LocationSelectionCore: Address, LocationSelectionType {
    public var coordinate: CLLocationCoordinate2D
    public var displayText: String?

    public var placemark: CLPlacemark?
    public var searchResult: LookupAddress?

    public var locationType: AnyPickable?

    public required init(coordinate: CLLocationCoordinate2D, displayText: String?) {
        self.coordinate = coordinate
        self.displayText = displayText
        super.init(id: UUID().uuidString)
        // also stores full address in Address
        self.fullAddress = displayText
    }

    public required init?(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return nil }
        self.placemark = placemark
        self.coordinate = coordinate

        if let address = placemark.postalAddress {
            let mailingAddress = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            self.displayText = mailingAddress.replacingOccurrences(of: "\n", with: ", ")
        }
        super.init(id: UUID().uuidString)
        // also stores address in Address props
        self.fullAddress = displayText
        self.postcode = placemark.postalCode
        self.streetName = placemark.thoroughfare
        self.streetNumberFirst = placemark.subThoroughfare
        self.state = placemark.administrativeArea
        self.suburb = placemark.subLocality
    }

    public required init?(searchResult: MPOLKitEntityProtocol) {
        guard let lookupAddress = searchResult as? LookupAddress else { return nil }

        // TODO: use address formatter?
        self.searchResult = lookupAddress
        self.coordinate = lookupAddress.coordinate
        self.displayText = lookupAddress.fullAddress
        super.init(id: UUID().uuidString)
        // also stores full address in Address props
        self.fullAddress = lookupAddress.fullAddress
        self.unit = lookupAddress.unitNumber
        self.streetNumberFirst = lookupAddress.streetNumberFirst
        self.streetName = lookupAddress.streetName
        self.postcode = lookupAddress.postalCode
    }

    public convenience init?(eventLocation: EventLocation?) {
        guard let eventLocation = eventLocation else { return nil }
        self.init(coordinate: eventLocation.coordinate, displayText: eventLocation.addressString)
    }

    public required init(from decoder: Decoder) throws {
        self.coordinate = CLLocationCoordinate2D.init()
        try super.init(from: decoder)
    }

    public required init(unboxer: Unboxer) throws {
        self.coordinate = CLLocationCoordinate2D.init()
        try super.init(unboxer: unboxer)
    }
}
