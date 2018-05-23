//
//  MKMapView+BoundingBox.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

extension MKMapView {
    public typealias BoundingBox = (northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D)
    
    public func boundingBox() -> BoundingBox {
        let nwPoint = MKMapPoint(x: MKMapRectGetMinX(visibleMapRect), y: visibleMapRect.origin.y)
        let sePoint = MKMapPoint(x: MKMapRectGetMaxX(visibleMapRect), y: MKMapRectGetMaxY(visibleMapRect))
        let nwCoordinate = MKCoordinateForMapPoint(nwPoint)
        let seCoordinate = MKCoordinateForMapPoint(sePoint)
        return (northWest: nwCoordinate, southEast: seCoordinate)
    }
}
