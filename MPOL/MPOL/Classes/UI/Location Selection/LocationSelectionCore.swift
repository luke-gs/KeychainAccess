//
//  LocationSelectionCore.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit
import PublicSafetyKit
import Contacts

/// Demo app implementation for a location selection
public class LocationSelectionCore: LocationSelectionType {
    public var coordinate: CLLocationCoordinate2D
    public var displayText: String?
    public var type: AnyPickable?

    public var placemark: CLPlacemark?
    public var searchResult: LookupAddress?

    public required init(coordinate: CLLocationCoordinate2D, displayText: String?, type: AnyPickable?) {
        self.coordinate = coordinate
        self.displayText = displayText
        self.type = type
    }

    public required init?(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return nil }
        self.placemark = placemark
        self.coordinate = coordinate

        if let address = placemark.postalAddress {
            let mailingAddress = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            self.displayText = mailingAddress.replacingOccurrences(of: "\n", with: ", ")
        }
    }

    public required init?(searchResult: MPOLKitEntityProtocol) {
        guard let lookupAddress = searchResult as? LookupAddress else { return nil }

        // TODO: use address formatter?
        self.searchResult = lookupAddress
        self.coordinate = lookupAddress.coordinate
        self.displayText = lookupAddress.fullAddress
    }

    public convenience init?(eventLocation: EventLocation?) {
        guard let eventLocation = eventLocation else { return nil }
        self.init(coordinate: eventLocation.coordinate, displayText: eventLocation.addressString, type: AnyPickable(eventLocation.involvementPickable!.title!.string))
    }
}
