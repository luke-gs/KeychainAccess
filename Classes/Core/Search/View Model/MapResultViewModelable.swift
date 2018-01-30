//
//  MapResultViewModelable.swift
//  MPOLKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MapKit

public enum LocationMapSearchType {

    case radius(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance)

    public var region: MKCoordinateRegion {
        switch self {
        case .radius(let coordinate, let radius):
            let distance = (radius * 1.1) * 2.0
            return MKCoordinateRegionMakeWithDistance(coordinate, distance, distance)
        }
    }

    public var coordinate: CLLocationCoordinate2D {
        switch self {
        case .radius(let coordinate, _):
            return coordinate
        }
    }

}


public protocol MapResultViewModelDelegate: class {

    /// Implement to receive notification when there are changes to the results.
    ///
    /// - Parameter viewModel: The view model that is executing the method.
    func mapResultViewModelDidUpdateResults(_ viewModel: MapResultViewModelable)

}

public protocol MapResultViewModelable: SearchResultModelable {

    // NEW STUFFS

    func itemsForResultsInSection(_ section: SearchResultSection) -> [FormItem]

    // OLD STUFFS
    
    /// Search enum, to identify the search type and parameters
    var searchType: LocationMapSearchType! { get set }

    /// Plugin for ETA calculation
    var travelEstimationPlugin: TravelEstimationPlugable { get set }
    
    /// Contains all the results for each section
    var results: [SearchResultSection] { get }

    /// Return all the annotations available on the map
    var allAnnotations: [MKAnnotation]? { get }

    func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView?

    func annotationViewDidSelect(for annotationView: MKAnnotationView, in mapView: MKMapView)

    /// A delegate that will be notified when there are changes to the results.
    weak var delegate: (MapResultViewModelDelegate & SearchResultMapViewController)? { get set }

    /// A search strategy to handle searches
    var searchStrategy: LocationSearchModelStrategy { get }

}


