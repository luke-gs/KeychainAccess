//
//  Manifest.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
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

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// Used to see the last time a location was retrieved
    open private(set) var lastLocationTime: Date? = nil
    fileprivate var locationManager: CLLocationManager = CLLocationManager()
    
    /// Used to get the last saved location.
    open var lastLocation: CLLocation? {
        get {
            return locationManager.location
        }
    }
    
    /// Used to set desired accuracy of location manager (defaults to nearest 10 meters)
    open var desiredAccuracy: CLLocationAccuracy {
        get {
            return locationManager.desiredAccuracy
        }
        set {
            locationManager.desiredAccuracy = newValue
        }
    }
    
    fileprivate var requestCompletionArray:[((CLLocation?, Error?) -> Void)] = []
    fileprivate var requestAuthorizationCompletionArray:[((CLLocation?, Error?) -> Void)] = []
    
    /// The singleton shared locationManager. This is the only instance of this class.
    public static let shared = LocationManager()
    
    private override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }
    
    
    /// Request a single location. Will automatically request authorization for both when in use and always depending if the valid description is in the info.plist
    ///
    /// - Parameters:
    ///   - completion:  Will return a CLLocation if one is found, or an Error (If authorization is not given of type LocationError).
    ///
    open func requestLocation(withCompletion completion:@escaping ((CLLocation?, Error?) -> Void)) {
        let authorizationStatus = CLLocationManager.authorizationStatus()

        if authorizationStatus == CLAuthorizationStatus.notDetermined {
            requestAuthorizationCompletionArray.append(completion)
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            return
        }
        
        if (authorizationStatus != .authorizedAlways  && authorizationStatus != .authorizedWhenInUse) || CLLocationManager.locationServicesEnabled() == false  {
            if (authorizationStatus == .denied) {
                completion(nil, LocationError.deniedAccess)
                return
            } else if CLLocationManager.locationServicesEnabled() == false {
                completion(nil, LocationError.locationServicesTurnedOff)
                return
            }
            completion(nil, nil)
            return
        }

        requestCompletionArray.append(completion)
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManager delegates
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            for completionBlock in requestCompletionArray {
                completionBlock(nil, nil)
            }
            requestCompletionArray.removeAll()
            return
        }
        lastLocationTime = Date()

        for completionBlock in requestCompletionArray {
            completionBlock(lastLocation, nil)
        }
        requestCompletionArray.removeAll()
        
        NotificationCenter.default.post(name: .LocationDidUpdate, object: self)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for completionBlock in requestCompletionArray {
            completionBlock(nil, error)
        }
        requestCompletionArray.removeAll()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != .authorizedAlways  && status != .authorizedWhenInUse) || CLLocationManager.locationServicesEnabled() == false  {
            if (status == .denied) {   // Authorisation not given
                for completionBlock in requestAuthorizationCompletionArray {
                    completionBlock(nil, LocationError.deniedAccess)
                }
                requestAuthorizationCompletionArray.removeAll()
            } else if CLLocationManager.locationServicesEnabled() == false {
                for completionBlock in requestAuthorizationCompletionArray {
                    completionBlock(nil, LocationError.locationServicesTurnedOff)
                }
                requestAuthorizationCompletionArray.removeAll()
            }
            return
        }
        
        for completionBlock in requestAuthorizationCompletionArray {
            requestLocation(withCompletion: completionBlock)
        }
        requestAuthorizationCompletionArray.removeAll()
    }
}

