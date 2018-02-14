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
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var altitude: CLLocationDistance?
    var horizontalAccuracy: CLLocationAccuracy?
    var verticalAccuracy: CLLocationAccuracy?
    var speed: CLLocationSpeed?
    var course: CLLocationDirection?
    var timestamp: Date?
    var addressString: String?

    private init() { }

    convenience init(location: CLLocation, addressString: String?) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.speed = location.speed
        self.course = location.course
        self.timestamp = location.timestamp
        self.addressString = addressString
    }

    public static func ==(lhs: EventLocation, rhs: EventLocation) -> Bool {
        return lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
        && lhs.altitude == rhs.altitude
        && lhs.horizontalAccuracy == rhs.horizontalAccuracy
        && lhs.verticalAccuracy == rhs.verticalAccuracy
        && lhs.speed == rhs.speed
        && lhs.course == rhs.course
        && lhs.timestamp == rhs.timestamp
        && lhs.addressString == rhs.addressString
    }
}
