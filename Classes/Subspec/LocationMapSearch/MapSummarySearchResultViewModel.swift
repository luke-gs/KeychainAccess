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
    
    public var title: String = "OVERVIEW"
    
    public var status: SearchState? {
        return aggregatedSearch?.state
    }
    
    public var searchType: LocationMapSearchType!
    
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
        guard let result = results.first else { return nil }

        for rawEntity in result.entities {
            let entity = rawEntity as! EntityMapSummaryDisplayable
            if entity.coordinate == coordinate {
                return entity
            }
        }
        
        return nil
    }
    
    // MARK: - AggregateSearchDelegate 
    
    public func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didBeginSearch request: AggregatedSearchRequest<U>) {
        self.results = self.processedResults(from: self.aggregatedSearch.results)
        delegate?.mapResultViewModelDidUpdateResults(self)
    }
    
    public func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didEndSearch request: AggregatedSearchRequest<U>) {
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
