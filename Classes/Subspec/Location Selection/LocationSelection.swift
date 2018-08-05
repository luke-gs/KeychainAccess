//
//  LocationSelection.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public class LocationSelection: NSObject, NSSecureCoding {
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var addressString: String?

    required public init(coordinate: CLLocationCoordinate2D, addressString: String?) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.addressString = addressString
    }

    /// Convenience accessor for location coordinate
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Coding

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case latitude
        case longitude
        case addressString
    }


    public required init?(coder aDecoder: NSCoder) {
        latitude = aDecoder.decodeDouble(forKey: Coding.latitude.rawValue)
        longitude = aDecoder.decodeDouble(forKey: Coding.longitude.rawValue)
        addressString = aDecoder.decodeObject(of: NSString.self, forKey: Coding.addressString.rawValue) as String?
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: Coding.latitude.rawValue)
        aCoder.encode(longitude, forKey: Coding.longitude.rawValue)
        aCoder.encode(addressString, forKey: Coding.addressString.rawValue)
    }

    // Equality

    public static func ==(lhs: LocationSelection, rhs: LocationSelection) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.addressString == rhs.addressString
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LocationSelection else { return false }
        return self.latitude == object.latitude
            && self.longitude == object.longitude
            && self.addressString == object.addressString
    }
}
