//
//  ManifestEntry+Location.swift
//  VCom
//
//  Created by Rod Brown on 30/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import CoreData
import CoreLocation

public extension ManifestEntry {
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            if let lat = latitude?.doubleValue, let long = longitude?.doubleValue {
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            return kCLLocationCoordinate2DInvalid
        }
        set {
            if CLLocationCoordinate2DIsValid(newValue) {
                latitude  = newValue.latitude  as NSNumber
                longitude = newValue.longitude as NSNumber
            } else {
                latitude = nil
                longitude = nil
            }
        }
    }
//    
//    public var address: Address? {
//        if let addressDict = additionalDetails?["address"] as? [String: String] {
//            return Address(json: addressDict)
//        }
//        return nil
//    }
    
}
