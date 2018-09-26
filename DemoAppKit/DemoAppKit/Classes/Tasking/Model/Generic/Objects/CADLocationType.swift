//
//  CADLocation.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation
import PublicSafetyKit

/// Protocol for a class representing a location
public protocol CADLocationType: class, Navigatable {

    // MARK: - Network
    var alertLevel: Int? { get set }
    var country: String? { get set }
    var fullAddress: String? { get set }
    var latitude: Double? { get set }
    var longitude: Double? { get set }
    var postalCode: String? { get set }
    var state: String? { get set }
    var streetName: String? { get set }
    var streetNumberFirst: String? { get set }
    var streetNumberLast: String? { get set }
    var streetType: String? { get set }
    var suburb: String? { get set }

    // MARK: - Generated
    var coordinate: CLLocationCoordinate2D? { get }
    var displayText: String? { get }
}
