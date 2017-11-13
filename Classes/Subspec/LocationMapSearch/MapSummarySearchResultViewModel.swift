//
//  MapSummarySearchResultViewModel.swift
//  Pods
//
//  Created by RUI WANG on 7/9/17.
//
//

import Foundation
import MapKit

open class MapSummarySearchResultViewModel<T: MPOLKitEntity, U : EntityMapSummaryDisplayable>: MapResultViewModelable, AggregatedSearchDelegate {
    public var searchType: LocationMapSearchType!


    public var title: String = "OVERVIEW"
    
    public var status: SearchState? {
        return aggregatedSearch?.state
    }

    public weak var delegate: MapResultViewModelDelegate?
    
    public var aggregatedSearch: AggregatedSearch<T>! {
        didSet {
            aggregatedSearch?.delegate = self
            aggregatedSearch?.performSearch()
        }
    }
    
    open var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()
    
    public var results: [SearchResultSection]  = []

    public required init() { }
    
    open func fetchResults(withParameters parameters: Parameterisable) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(with searchType: LocationMapSearchType) {
        MPLRequiresConcreteImplementation()
    }
    
    /// Lookup the first entity matches the coordinate
    ///
    /// - Parameter coordinate: The coordinate of target location
    /// - Returns: The first entity matches the same coordinate
    open func entity(for coordinate: CLLocationCoordinate2D) -> EntityMapSummaryDisplayable? {
        MPLRequiresConcreteImplementation()
    }
    
    open func coordinate(for entity: MPOLKitEntity) -> CLLocationCoordinate2D {
        MPLRequiresConcreteImplementation()
    }

    open func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {
        MPLRequiresConcreteImplementation()
    }

    open func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        MPLRequiresConcreteImplementation()
    }

    // MARK: - AggregateSearchDelegate 
    
    public func aggregatedSearch<T>(_ aggregatedSearch: AggregatedSearch<T>, didBeginSearch request: AggregatedSearchRequest<T>) {
        self.results = self.processedResults(from: self.aggregatedSearch.results)
        delegate?.mapResultViewModelDidUpdateResults(self)
    }
    
    public func aggregatedSearch<T>(_ aggregatedSearch: AggregatedSearch<T>, didEndSearch request: AggregatedSearchRequest<T>) {
        self.results = self.processedResults(from: self.aggregatedSearch.results)
        delegate?.mapResultViewModelDidUpdateResults(self)
    }
    
    private func processedResults(from rawResults: [AggregatedResult<T>]) -> [SearchResultSection] {
        let processedResults: [SearchResultSection] = rawResults.map { (rawResult) -> SearchResultSection in
            return SearchResultSection(title: "OVERVIEW",
                                       entities: rawResult.entities,
                                       isExpanded: true,
                                       state: rawResult.state,
                                       error: rawResult.error)
        }
        
        return processedResults
    }
}

extension CLLocationCoordinate2D: Equatable { }

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
