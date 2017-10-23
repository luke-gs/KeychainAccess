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

enum LocationError: Error {
    case deniedAccess
    case locationServicesTurnedOff
    
    var localizedDescription: String {
        switch self {
        case .deniedAccess:                 return NSLocalizedString("Location Service Denied", comment: "Location service denied")
        case .locationServicesTurnedOff:    return NSLocalizedString("Location Service Turned Off", comment: "Location service turned off")
        }
    }
}

public extension NSNotification.Name {
    static let LocationDidUpdate = NSNotification.Name(rawValue: "LocationDidUpdate")
}

public final class LocationManager: NSObject {
    
    /// The singleton shared locationManager. This is the only instance of this class.
    public static let shared = LocationManager()
    
    static let interval:TimeInterval = 5*60
    static let timeBuffer:Double = 60
    
    /// Used to see the last time a location was retrieved
    open var lastLocationTime: Date? {
        get {
            return lastLocation?.timestamp
        }
    }
    
    /// Automatic timer to periodically update location if no location has been obtained recently.
    fileprivate var timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
        if let time = LocationManager.shared.lastLocationTime {
            if Date().timeIntervalSince(time) > timeBuffer { // Refresh location
                LocationManager.shared.requestLocation().always {
                }
            }
        } else {
            LocationManager.shared.requestLocation().always {
            }
        }
    }
    
    /// Used to get the last saved location.
    open var lastLocation: CLLocation? = nil
    
    private override init() {
        super.init()
    }
    
    /// Request a single location. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Return:
    ///     - A promise with a Location
    ///
    open func requestLocation() -> Promise<CLLocation> {
        return CLLocationManager.promise().then { location -> CLLocation in
            self.lastLocation = location
            return location
        }
    }
}

