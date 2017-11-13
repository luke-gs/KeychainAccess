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
    case radiusSearch(coordinate: CLLocationCoordinate2D, radius: Double)
    //    case boundingSearch(MKPolygon)
    //    case parametersSearch(Searchable)
    
    public enum Builder {
        public static func radiusSearch(coordinate: CLLocationCoordinate2D, radius: Double = 300) -> LocationMapSearchType {
            return LocationMapSearchType.radiusSearch(coordinate: coordinate, radius: radius)
        }
    }
    
    public static var make: LocationMapSearchType.Builder.Type {
        return LocationMapSearchType.Builder.self
    }
}

public protocol MapResultViewModelDelegate: class {

    /// Implement to receive notification when there are changes to the results.
    ///
    /// - Parameter viewModel: The view model that is executing the method.
    func mapResultViewModelDidUpdateResults(_ viewModel: MapResultViewModelable)

}

public protocol MapResultViewModelable: SearchResultModelable {

    init()
    
    /// Plugin for ETA calucation
    var travelEstimationPlugin: TravelEstimationPlugable { get set }
    
    /// Contains all the results for each section
    var results: [SearchResultSection] { get set }
    
    /// Search enum, to identifiy the seach type and parameters
    var searchType: LocationMapSearchType! { get set }

    /// Returns the entity that is associciated with the provided coordinate
    /// Searches in the results for a matching entity
    func entity(for coordinate: CLLocationCoordinate2D) -> MPOLKitEntity?

    /// Return a displayable value for the first entity matches the coordinate
    ///
    /// - Parameter coordinate: The coordinate of target location
    func entityDisplayable(for coordinate: CLLocationCoordinate2D) -> EntityMapSummaryDisplayable?
    
    func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation?

    /// The view for each annotation view for the specific mapView
    /// Subclasses will need to provode their own implementations to provide annotations
    func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView?
    
    /// A delegate that will be notified when there are changes to the results.
    weak var delegate: MapResultViewModelDelegate? { get set }

    /// Fetch results with the given parameters.
    ///
    /// - Parameter parameters: Dictionary containing look up information.
    func fetchResults(withParameters parameters: Parameterisable)

    /// Fetch results with the given coordinate.
    ///
    /// - Parameter coordinate: Look up coordinate.
    func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D)

    /// Fetch results with the searchType.
    ///
    /// - Parameter searchType: SearchType with associate value.
    func fetchResults(with searchType: LocationMapSearchType)
    
}
