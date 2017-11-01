//
//  Manifest.swift
//  MPOLKit
//
//  Created by Valery Shorinov on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

open class GeolocationPlugin: PluginType {
    static let locationLatitudeKey = "X-GPS-Latitude"
    static let locationLongitudeKey = "X-GPS-Longitude"
    static let locationTimeOfDayKey = "X-GPS-Time-Of-Day"
    static let locationDataAge = "X-GPS-Data-Age"
    static let locationHorizontalAccuracyKey = "X-GPS-Horizontal-Accuracy"
    static let locationVerticalAccuracyKey = "X-GPS-Altitude-Accuracy"
    static let locationAltitudeKey = "X-GPS-Altitude"
    static let locationDirectionOfTravelKey = "X-GPS-Direction-Of-Travel"
    static let locationSpeed = "X-GPS-Speed"
    
    open func adapt(_ urlRequest: URLRequest) -> URLRequest {
        var adaptedRequest = urlRequest
        
        func minutesSinceMidnight(start: Date) -> Int {
            let units : Set<Calendar.Component> = [.hour, .minute]
            
            let components = Calendar.current.dateComponents(units, from: start)
            return 60 * (components.hour ?? 0) + (components.minute ?? 0)
        }
        
        func dataAge(from: Date) -> Int {
            let timeInterval = Date().timeIntervalSince(from)
            
            return Int(timeInterval)
        }
        
        if let location = LocationManager.shared.lastLocation {
            adaptedRequest.addValue(String(location.coordinate.latitude), forHTTPHeaderField: GeolocationPlugin.locationLatitudeKey)
            adaptedRequest.addValue(String(location.coordinate.longitude), forHTTPHeaderField: GeolocationPlugin.locationLongitudeKey)
            adaptedRequest.addValue(String(location.altitude), forHTTPHeaderField: GeolocationPlugin.locationAltitudeKey)
            adaptedRequest.addValue(String(location.horizontalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationHorizontalAccuracyKey)
            adaptedRequest.addValue(String(location.verticalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationVerticalAccuracyKey)
            adaptedRequest.addValue(String(minutesSinceMidnight(start: location.timestamp)), forHTTPHeaderField: GeolocationPlugin.locationTimeOfDayKey)
            adaptedRequest.addValue(String(dataAge(from: location.timestamp)), forHTTPHeaderField: GeolocationPlugin.locationDataAge)

            if location.course >= 0.0 { // Check if valid
                adaptedRequest.addValue(String(location.course), forHTTPHeaderField: GeolocationPlugin.locationDirectionOfTravelKey)
            }
            
            if location.speed >= 0.0 { // Check if valid
                adaptedRequest.addValue(String(location.speed), forHTTPHeaderField: GeolocationPlugin.locationSpeed)
            }
        }
        
        return adaptedRequest
    }
}
