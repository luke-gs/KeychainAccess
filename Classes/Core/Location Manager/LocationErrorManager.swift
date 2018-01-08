//
//  LocationErrorManager.swift
//  MPOLKit
//
//  Created by QHMW64 on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit

public enum LocationErrorRecoveryPolicy {
    case indeterminateLocation
    case lastLocation
    case customLocation(CLLocation)
    case calculated(() -> CLLocation)
}

public protocol LocationErrorManageable {
    var failurePolicy: LocationErrorRecoveryPolicy { get }
    func handleError(_ error: Error) -> Promise<CLLocation>
}

public enum LocationErrorManagerError: Error {
    case recoveryFailed
}

public final class LocationErrorManager: LocationErrorManageable {

    public init(failurePolicy policy: LocationErrorRecoveryPolicy = .indeterminateLocation) {
        self.failurePolicy = policy
    }

    public var failurePolicy: LocationErrorRecoveryPolicy = .indeterminateLocation

    public func handleError(_ error: Error) -> Promise<CLLocation> {

        switch CLError(_nsError: error as NSError).code {
        case .denied:
            return Promise<CLLocation>(error: LocationErrorManagerError.recoveryFailed)
        default:
            return Promise<CLLocation> { fufill, reject in
                switch failurePolicy {
                case .indeterminateLocation:
                    reject(LocationErrorManagerError.recoveryFailed)
                case .customLocation(let location):
                    fufill(location)
                case .calculated(let block):
                    fufill(block())
                case .lastLocation:
                    if let location = LocationManager.shared.lastLocation {
                        fufill(location)
                    } else {
                        reject(LocationErrorManagerError.recoveryFailed)
                    }
                }
            }
        }
    }
}

extension CLLocation {
    static var indeterminateLocation: CLLocation {
        let location2d = kCLLocationCoordinate2DInvalid
        return CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
    }
}
