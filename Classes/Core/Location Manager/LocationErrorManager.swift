//
//  LocationErrorManager.swift
//  MPOLKit
//
//  Created by QHMW64 on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

public enum LocationErrorRecoveryPolicy {
    case indeterminateLocation
    case customLocation(CLLocation)
    case calculated(() -> CLLocation)

    var location: CLLocation {
        switch self {
        case .indeterminateLocation:
            return CLLocation.indeterminateLocation
        case .customLocation(let location):
            return location
        case .calculated(let block):
            return block()
        }
    }
}

public protocol LocationErrorManagable {
    var failurePolicy: LocationErrorRecoveryPolicy { get }
    func recover(_ error: Error) -> CLLocation
}

public final class LocationErrorManager: LocationErrorManagable {

    public init(failurePolicy policy: LocationErrorRecoveryPolicy = .indeterminateLocation) {
        self.failurePolicy = policy
    }

    public var failurePolicy: LocationErrorRecoveryPolicy = .indeterminateLocation

    public func recover(_ error: Error) -> CLLocation {
        if let location = LocationManager.shared.lastLocation {
            return location
        } else {
            var location: CLLocation?
            // Better error handling here
            switch CLError(_nsError: error as NSError).code {
            case .denied:
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            default:
                break
            }
            return location ?? failurePolicy.location
        }
    }
}

fileprivate extension CLLocation {
    static var indeterminateLocation: CLLocation {
        return CLLocation(latitude: 0.0, longitude: 0.0)
    }
}
