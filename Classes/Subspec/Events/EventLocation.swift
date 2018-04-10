//
//  EventLocation.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public class EventLocation: NSObject, NSSecureCoding {
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var addressString: String?

    required public init(location: CLLocationCoordinate2D, addressString: String?) {
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.addressString = addressString
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

    public static func ==(lhs: EventLocation, rhs: EventLocation) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.addressString == rhs.addressString
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? EventLocation else { return false }
        return self.latitude == object.latitude
            && self.longitude == object.longitude
            && self.addressString == object.addressString
    }
}
