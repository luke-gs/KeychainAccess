//
//  MKMapView+BoundingBox.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

extension MKMapView {

    public struct BoundingBox: Equatable {
        var northWest: CLLocationCoordinate2D
        var southEast: CLLocationCoordinate2D

        var northWestLocation: CLLocation {
            return CLLocation(latitude: northWest.latitude, longitude: northWest.longitude)
        }

        var southEastLocation: CLLocation {
            return CLLocation(latitude: southEast.latitude, longitude: southEast.longitude)
        }
    }

    public func boundingBox() -> BoundingBox {
        let nwPoint = MKMapPoint(x: MKMapRectGetMinX(visibleMapRect), y: visibleMapRect.origin.y)
        let sePoint = MKMapPoint(x: MKMapRectGetMaxX(visibleMapRect), y: MKMapRectGetMaxY(visibleMapRect))
        let nwCoordinate = MKCoordinateForMapPoint(nwPoint)
        let seCoordinate = MKCoordinateForMapPoint(sePoint)
        return BoundingBox(northWest: nwCoordinate, southEast: seCoordinate)
    }
}
