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

    open func numberOfSections() -> Int {
        return results.count
    }

    open func numberOfItems(in section: Int) -> Int {
        let result = results[section]
        switch result.state {
        case .finished where result.error != nil:
            return 0
        case .finished:
            if section == 0 {
                return 2
            } else {
                return result.entities.count
            }
        default:
            break
        }
        return 0

    }
    
    open func fetchResults(withParameters parameters: Parameterisable) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(with searchType: LocationMapSearchType) {
        MPLRequiresConcreteImplementation()
    }

    open func entity(for coordinate: CLLocationCoordinate2D) -> MPOLKitEntity? {
        MPLRequiresConcreteImplementation()
    }

    /// Lookup the first entity matches the coordinate
    ///
    /// - Parameter coordinate: The coordinate of target location
    /// - Returns: The first entity matches the same coordinate
    open func entityDisplayable(for coordinate: CLLocationCoordinate2D) -> EntityMapSummaryDisplayable? {
        MPLRequiresConcreteImplementation()
    }
    
    open func coordinate(for entity: MPOLKitEntity) -> CLLocationCoordinate2D {
        MPLRequiresConcreteImplementation()
    }

    open func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {
        MPLRequiresConcreteImplementation()
    }

    open func annotations() -> [MKAnnotation]? {
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
