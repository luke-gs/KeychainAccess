//
//  MapResultViewModelable.swift
//  MPOLKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MapKit

public struct LocationMapSearchType {
    public enum MapSearchType {
        case radius
    }

    private let mapSearchType: MapSearchType
    public let coordinate: CLLocationCoordinate2D
    public let radius: Double

    private init(coordinate: CLLocationCoordinate2D, radius: Double, mapSearchType: MapSearchType) {
        self.coordinate = coordinate
        self.radius = radius
        self.mapSearchType = mapSearchType
    }

    public static func radiusSearch(from coordinate: CLLocationCoordinate2D, withRadius radius: Double = 300) -> LocationMapSearchType {
        return LocationMapSearchType(coordinate: coordinate, radius: radius, mapSearchType: .radius)
    }

    public func region() -> MKCoordinateRegion {
        switch mapSearchType {
        case .radius:
            let distance = radius * 2.0 + 100.0
            return MKCoordinateRegionMakeWithDistance(coordinate, distance, distance)
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

    /// Plugin for ETA calculation
    var travelEstimationPlugin: TravelEstimationPlugable { get set }
    
    /// Contains all the results for each section
    var results: [SearchResultSection] { get }

    /// Search enum, to identify the search type and parameters
    var searchType: LocationMapSearchType! { get set }

    /// Return all the annotations available on the map
    var allAnnotations: [MKAnnotation]? { get }

    func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation?

    /// The view for each annotation view for the specific mapView
    /// Subclasses will need to provide their own implementations to provide annotations
    func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView?

    func mapDidSelectAnnotationView(for annotationView: MKAnnotationView)

    /// A delegate that will be notified when there are changes to the results.
    weak var delegate: (MapResultViewModelDelegate & SearchResultMapViewController)? { get set }

    /// A search strategy to handle searches
    var searchStrategy: LocationSearchModelStrategy { get }

}


