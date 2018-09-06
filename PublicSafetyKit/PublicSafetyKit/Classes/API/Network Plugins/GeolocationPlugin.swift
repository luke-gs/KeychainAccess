//
//  GeolocationPlugin.swift
//  MPOLKit
//
//  Created by Valery Shorinov on 18/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import CoreLocation
import PromiseKit

/// Plugin that will inject **X-GPS-Latitude**, **X-GPS-Longitude**, **X-GPS-Time-Of-Day**, **X-GPS-Data-Age**,
/// **X-GPS-Horizontal-Accuracy**, **X-GPS-Altitude-Accuracy**, **X-GPS-Altitude-Accuracy**, **X-GPS-Altitude**, **X-GPS-Direction-Of-Travel**,
/// **X-GPS-Speed**, and **X-GPS-Timestamp**. X-GPS-Time-Of-Day will be removed in the future.
/// to the header of requests. The data will be populated using `CLLocation`, sourced from internal LocationManager.
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
    static let locationTimestamp = "X-GPS-Timestamp"

    /// Whether to use the last location returned to LocationManager rather than requesting a new one each time
    private let useLastLocation: Bool

    /// Init
    ///
    /// - Parameter useLastLocation: Whether to use the last location returned to LocationManager rather than requesting a new one each time
    public init(useLastLocation: Bool = false) {
        self.useLastLocation = useLastLocation

        if useLastLocation {
            // Trigger at least one location fetch so lastLocation is updated
            LocationManager.shared.requestLocation().cauterize()
        }
    }
    
    open func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        var adaptedRequest = urlRequest

        let locationPromise: Promise<CLLocation>
        if useLastLocation {
            // Use the last location if found, otherwise let the error manager handle it as location unknown
            if let location = LocationManager.shared.lastLocation {
                locationPromise = Promise<CLLocation>.value(location)
            } else {
                let clError = NSError(domain: "", code: CLError.locationUnknown.rawValue, userInfo: nil)
                locationPromise = Promise<CLLocation>(error: clError)
            }
        } else {
            // Fetch a new location
            locationPromise = LocationManager.shared.requestLocation()
        }

        return locationPromise.recover { error -> Promise<CLLocation> in
            return LocationManager.shared.errorManager.handleError(error)
        }.then { [weak self] location -> Promise<URLRequest> in
            guard let `self` = self else {
                return Promise.value(urlRequest)
            }
            self.injectLocation(into: &adaptedRequest, location: location)
            return Promise.value(adaptedRequest)
        }
    }

    public func injectLocation(into request: inout URLRequest, location: CLLocation) {
        request.setValue(String(location.coordinate.latitude), forHTTPHeaderField: GeolocationPlugin.locationLatitudeKey)
        request.setValue(String(location.coordinate.longitude), forHTTPHeaderField: GeolocationPlugin.locationLongitudeKey)
        request.setValue(String(location.altitude), forHTTPHeaderField: GeolocationPlugin.locationAltitudeKey)
        request.setValue(String(location.horizontalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationHorizontalAccuracyKey)
        request.setValue(String(location.verticalAccuracy), forHTTPHeaderField: GeolocationPlugin.locationVerticalAccuracyKey)
        request.setValue(String(location.timestamp.timeSinceNow()), forHTTPHeaderField: GeolocationPlugin.locationDataAge)

        // This is deprecated, remove when VicPol is fully ported.
        request.setValue(String(location.timestamp.minutesSinceMidnight()), forHTTPHeaderField: GeolocationPlugin.locationTimeOfDayKey)

        if let dateValue = ISO8601DateTransformer.shared.reverse(location.timestamp) {
            request.setValue(dateValue, forHTTPHeaderField: GeolocationPlugin.locationTimestamp)
        }

        if location.course >= 0.0 { // Check if valid
            request.setValue(String(location.course), forHTTPHeaderField: GeolocationPlugin.locationDirectionOfTravelKey)
        }

        if location.speed >= 0.0 { // Check if valid
            request.setValue(String(location.speed), forHTTPHeaderField: GeolocationPlugin.locationSpeed)
        }
    }

}
