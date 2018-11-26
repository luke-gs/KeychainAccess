//
//  EventLocation.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import PublicSafetyKit

/// Data model for a generic location selection including lat/lon and an address string
public class EventLocation: NSObject, Codable {

    // MARK: - PUBLIC

    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var addressString: String?
    public var involvement: String?

    required public init(coordinate: CLLocationCoordinate2D, addressString: String?, involvement: String?) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.addressString = addressString
        self.involvement = involvement
    }

    public convenience init?(locationSelection: LocationSelectionCore?) {
        guard let locationSelection = locationSelection else { return nil }
        self.init(coordinate: locationSelection.coordinate, addressString: locationSelection.displayText, involvement: locationSelection.locationType?.title?.string)
    }

    /// Convenience init for a placemark
    public init?(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return nil }

        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude

        if let address = placemark.postalAddress {
            let mailingAddress = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            self.addressString = mailingAddress.replacingOccurrences(of: "\n", with: ", ")
        }
    }

    /// Convenience accessor for location coordinate
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case addressString
        case involvement
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        addressString = try container.decodeIfPresent(String.self, forKey: .addressString)
        involvement = try container.decodeIfPresent(String.self, forKey: .involvement)
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: CodingKeys.latitude)
        try container.encode(longitude, forKey: CodingKeys.longitude)
        try container.encode(addressString, forKey: CodingKeys.addressString)
        try container.encode(involvement, forKey: CodingKeys.involvement)
    }

    // MARK: - Equality

    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? EventLocation else { return false }
        return self.latitude == object.latitude
            && self.longitude == object.longitude
            && self.addressString == object.addressString
    }
}
