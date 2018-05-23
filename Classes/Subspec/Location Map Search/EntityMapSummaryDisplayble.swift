//
//  EntityMapSummaryDisplayable.swift
//  Pods
//
//  Created by RUI WANG on 8/9/17.
//
//

import Foundation
import MapKit

public protocol EntityMapSummaryDisplayable: EntitySummaryDisplayable {

    var coordinate: CLLocationCoordinate2D? { get }

}

open class EntityMapSummaryAnnotation: MKPointAnnotation {

    open var mapSummaryDisplayable: EntityMapSummaryDisplayable? {
        didSet {
            if let coordinate = mapSummaryDisplayable?.coordinate {
                self.coordinate = coordinate
            } else {
                self.coordinate = kCLLocationCoordinate2DInvalid
            }
        }
    }

}
