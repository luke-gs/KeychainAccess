//
//  CLLocationCoordinate2D+Equatable.swift
//  Alamofire
//
//  Created by QHMW64 on 14/11/17.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
