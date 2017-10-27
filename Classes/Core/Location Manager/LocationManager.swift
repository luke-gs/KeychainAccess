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

public final class LocationManager: NSObject {
    
    /// The singleton shared locationManager. This is the only instance of this class.
    public static let shared = LocationManager()
    
    /// Used to see the last time a location was retrieved
    open var lastLocationTime: Date? {
        get {
            return lastLocation?.timestamp
        }
    }
    
    /// Used to get the last saved location.
    open var lastLocation: CLLocation? = nil
    open var lastPlacemark: CLPlacemark? = nil
    
    private override init() {
        super.init()
    }
    
    /// Request a single location. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Location
    ///
    @discardableResult
    open func requestLocation() -> Promise<CLLocation> {
        return CLLocationManager.promise().then { location -> CLLocation in
            self.lastLocation = location
            NotificationCenter.default.post(name: .LocationDidUpdate, object: self)
            return location
        }
    }
    
    /// Request a location to be reversegeocoded. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Placemark
    ///
    open func requestPlacemark(from location: CLLocation) -> Promise<CLPlacemark> {
        return CLGeocoder().reverseGeocode(location: location)
    }
    
    /// Request a single location reversegeocoded. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Placemark
    ///
    @discardableResult
    open func requestPlacemark() -> Promise<CLPlacemark> {
        return CLLocationManager.promise().then { location in
            self.lastLocation = location
            NotificationCenter.default.post(name: .LocationDidUpdate, object: self)
            return CLGeocoder().reverseGeocode(location: location).then { placemark -> CLPlacemark in
                self.lastPlacemark = placemark
                return placemark
            }
        }
    }
}

