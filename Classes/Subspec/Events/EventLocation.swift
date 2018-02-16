//
//  EventLocation.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public struct EventLocation: Codable {
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var altitude: CLLocationDistance?
    var horizontalAccuracy: CLLocationAccuracy?
    var verticalAccuracy: CLLocationAccuracy?
    var speed: CLLocationSpeed?
    var course: CLLocationDirection?
    var timestamp: Date?
}
