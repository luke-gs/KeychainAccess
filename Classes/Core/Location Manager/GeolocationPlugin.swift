//
//  GeolocationPlugin.swift
//  MPOLKit
//
//  Created by Valery Shorinov on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import CoreLocation
import PromiseKit

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
    
    public init() {

    }
    
    open func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        var adaptedRequest = urlRequest

        if let location = LocationManager.shared.lastLocation {
            adaptedRequest.setValue(String(location.coordinate.latitude), forHTTPHeaderField: GeolocationPlugin.locationLatitudeKey)
            adaptedRequest.setValue(String(location.coordinate.longitude), forHTTPHeaderField: GeolocationPlugin.locationLongitudeKey)
            adaptedRequest.setValue(String(location.altitude), forHTTPHeaderField: GeolocationPlugin.locationAltitudeKey)
            adaptedRequest.setValue(String(location.horizontalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationHorizontalAccuracyKey)
            adaptedRequest.setValue(String(location.verticalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationVerticalAccuracyKey)
            adaptedRequest.setValue(String(location.timestamp.minutesSinceMidnight()), forHTTPHeaderField: GeolocationPlugin.locationTimeOfDayKey)
            adaptedRequest.setValue(String(location.timestamp.timeSinceNow()), forHTTPHeaderField: GeolocationPlugin.locationDataAge)

            if location.course >= 0.0 { // Check if valid
                adaptedRequest.setValue(String(location.course), forHTTPHeaderField: GeolocationPlugin.locationDirectionOfTravelKey)
            }
            
            if location.speed >= 0.0 { // Check if valid
                adaptedRequest.setValue(String(location.speed), forHTTPHeaderField: GeolocationPlugin.locationSpeed)
            }
        }

        return LocationManager.shared.requestLocation().recover { error -> CLLocation in
            return LocationManager.shared.lastLocation ?? CLLocation()
            }.then { _ -> Promise<URLRequest> in
                return Promise(value: adaptedRequest)
        }
    }

}
