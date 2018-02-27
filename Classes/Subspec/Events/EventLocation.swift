//
//  EventLocation.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public class EventLocation: Codable, Equatable {
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var addressString: String?

    required public init(location: CLLocationCoordinate2D, addressString: String?) {
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.addressString = addressString
    }

    public static func ==(lhs: EventLocation, rhs: EventLocation) -> Bool {
        return lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
        && lhs.addressString == rhs.addressString
    }
}
