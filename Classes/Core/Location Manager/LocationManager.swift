//
//  LocationManager.swift
//  MPOLKit
//
//  Created by Val Shorinov on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import CoreLocation

public extension NSNotification.Name {
    static let LocationDidUpdate = NSNotification.Name(rawValue: "LocationDidUpdate")
}

enum LocationError: LocalizedError {
    case authorizationError
    
    var errorDescription: String? {
        switch self {
        case .authorizationError: return "No authorization given to location services"
        }
    }
}

public final class LocationManager: NSObject {
    
    /// The singleton shared locationManager. This is the only instance of this class.
    public static let shared = LocationManager()
    
    /// Used to see the last time a location was retrieved
    public var lastLocationTime: Date? {
        get {
            return lastLocation?.timestamp
        }
    }

    public var errorManager: LocationErrorManageable = LocationErrorManager()
    
    /// Used to get the last saved location.
    public var lastLocation: CLLocation? = nil
    public var lastPlacemark: CLPlacemark? = nil
    
    private override init() {
        super.init()
    }
    
    /// Request a single location. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Location
    ///
    @discardableResult
    public func requestLocation() -> Promise<CLLocation> {
        return CLLocationManager.requestLocation().lastValue.map { location -> CLLocation in
            self.lastLocation = location
            NotificationCenter.default.post(name: .LocationDidUpdate, object: self)
            return location
        }
    }
    
    /// Requests authorization from the CLLocationManager
    @discardableResult
    public func requestWhenInUseAuthorization() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        _ = CLLocationManager.requestAuthorization().then { status -> Promise<Void> in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                resolver.fulfill(())
            default:
                resolver.reject(LocationError.authorizationError)
            }
            return Promise<Void>.value(())
        }
        return promise
    }
    
    /// Request a location to be reversegeocoded. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Placemark
    ///
    public func requestPlacemark(from location: CLLocation) -> Promise<CLPlacemark> {
        return CLGeocoder().reverseGeocode(location: location).firstValue
    }
    
    /// Request a single location reversegeocoded. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Placemark
    ///
    @discardableResult
    public func requestPlacemark() -> Promise<CLPlacemark> {
        return self.requestLocation().then { location in
            return CLGeocoder().reverseGeocode(location: location).firstValue.map { placemark -> CLPlacemark in
                self.lastPlacemark = placemark
                return placemark
            }
        }
    }
}

