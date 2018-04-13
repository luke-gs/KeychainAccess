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
    case invalidLocation
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

    public init(failurePolicy policy: LocationErrorRecoveryPolicy = .invalidLocation) {
        self.failurePolicy = policy
    }

    public var failurePolicy: LocationErrorRecoveryPolicy = .invalidLocation

    public func handleError(_ error: Error) -> Promise<CLLocation> {

        switch CLError(_nsError: error as NSError).code {
        case .denied:
            return Promise<CLLocation>(error: LocationErrorManagerError.recoveryFailed)
        default:
            return Promise<CLLocation> { seal in
                switch failurePolicy {
                case .invalidLocation:
                    seal.reject(LocationErrorManagerError.recoveryFailed)
                case .customLocation(let location):
                    seal.fulfill(location)
                case .calculated(let block):
                    seal.fulfill(block())
                case .lastLocation:
                    if let location = LocationManager.shared.lastLocation {
                        seal.fulfill(location)
                    } else {
                        seal.reject(LocationErrorManagerError.recoveryFailed)
                    }
                }
            }
        }
    }
}

extension CLLocation {
    static var invalidLocation: CLLocation {
        let location2d = kCLLocationCoordinate2DInvalid
        return CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
    }
}
