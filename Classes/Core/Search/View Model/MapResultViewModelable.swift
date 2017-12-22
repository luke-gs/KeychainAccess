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

    /// Plugin for ETA calucation
    var travelEstimationPlugin: TravelEstimationPlugable { get set }
    
    /// Contains all the results for each section
    var results: [SearchResultSection] { get set }

    /// The number of sections in the sidebar collection view
    func numberOfSections() -> Int

    /// The number of items in the sidebar collection view
    func numberOfItems(in section: Int) -> Int
    
    /// Search enum, to identifiy the seach type and parameters
    var searchType: LocationMapSearchType! { get set }

    /// Return all the annotations available on the map
    var allAnnotations: [MKAnnotation]? { get }

    /// Return a displayable value for the first entity matches the coordinate
    ///
    /// - Parameter coordinate: The coordinate of target location
    func entityDisplayable(for annotation: MKAnnotation) -> EntityMapSummaryDisplayable?

    /// Returns a presentablefor for the annotation
    ///
    /// - Parameter annotation: The annotation
    /// - Returns: The presentable
    func entityPresentable(for annotation: MKAnnotation) -> Presentable?

    func entity(for annotation: MKAnnotation) -> MPOLKitEntity?

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
