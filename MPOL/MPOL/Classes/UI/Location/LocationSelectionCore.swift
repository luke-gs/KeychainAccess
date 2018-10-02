//
//  LocationSelectionCore.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit
import PublicSafetyKit

/// Demo app implementation for a location selection
public class LocationSelectionCore: LocationSelectionType {
    public var coordinate: CLLocationCoordinate2D
    public var displayText: String?
    public var searchResult: LookupAddress?

    public required init(coordinate: CLLocationCoordinate2D, displayText: String?) {
        self.coordinate = coordinate
        self.displayText = displayText
    }

    public required init?(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return nil }
        self.coordinate = coordinate

        if let formattedAddress = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
            self.displayText = formattedAddress.joined(separator: " ")
        }
    }

    public required convenience init?(searchResult: MPOLKitEntityProtocol) {
        guard let lookupAddress = searchResult as? LookupAddress else { return nil }

        // TODO: use address formatter?
        self.init(coordinate: lookupAddress.coordinate, displayText: lookupAddress.fullAddress)
        self.searchResult = lookupAddress
    }
}

