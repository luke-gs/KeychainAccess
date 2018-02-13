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

    init(latitude: CLLocationDegrees?,
        longitude: CLLocationDegrees?,
        altitude: CLLocationDistance?,
        horizontalAccuracy: CLLocationAccuracy?,
        verticalAccuracy: CLLocationAccuracy?,
        speed: CLLocationSpeed?,
        course: CLLocationDirection?,
        timestamp: Date?)
    {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
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
    }
}
