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

    func mapAnnotationThumbnail() -> UIImage?
}

public protocol EntityMapSummaryDecoratable {
    
    func decorate(with locationSummary: EntityMapSummaryDisplayable)
    
}

