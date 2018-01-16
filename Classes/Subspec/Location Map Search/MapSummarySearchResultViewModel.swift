//
//  MapSummarySearchResultViewModel.swift
//  Pods
//
//  Created by RUI WANG on 7/9/17.
//
//

import Foundation
import MapKit

open class MapSummarySearchResultViewModel<T: MPOLKitEntity>: MapResultViewModelable, AggregatedSearchDelegate {

    private var _entityAnnotationMappings: [EntityAnnotationMapping]? = []

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
    
    public var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()
    
    public var results: [SearchResultSection]  = [] {
        didSet {
            var mapAnnotations = [EntityAnnotationMapping]()
            for section in results {
                let annotations = section.entities.flatMap({ entity -> EntityAnnotationMapping? in
                    guard let annotation = mapAnnotation(for: entity) else {
                        return nil
                    }
                    return EntityAnnotationMapping(entity: entity, annotation: annotation)
                })
                mapAnnotations.append(contentsOf: annotations)
            }
            self._entityAnnotationMappings = mapAnnotations
        }
    }

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public init(summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }

    public func numberOfSections() -> Int {
        return results.count
    }

    public func numberOfItems(in section: Int) -> Int {
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

    // TODO: - These could be refactored.
    open func fetchResults(withParameters parameters: Parameterisable) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D) {
        MPLRequiresConcreteImplementation()
    }
    
    open func fetchResults(with searchType: LocationMapSearchType) {
        MPLRequiresConcreteImplementation()
    }

    public func entity(for annotation: MKAnnotation) -> MPOLKitEntity? {
        guard let index = _entityAnnotationMappings?.index(where: { mapping -> Bool in
            return mapping.annotation === annotation
        }) else {
            return nil
        }
        return _entityAnnotationMappings?[index].entity
    }

    /// Lookup the first entity matches the coordinate
    ///
    /// - Parameter coordinate: The coordinate of target location
    /// - Returns: The first entity matches the same coordinate

    public func entityDisplayable(for annotation: MKAnnotation) -> EntityMapSummaryDisplayable? {
        guard let entity = entity(for: annotation), let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else {
            return nil
        }

        return summary
    }

    public func entityPresentable(for annotation: MKAnnotation) -> Presentable? {
        guard let entity = entity(for: annotation), let presentable = summaryDisplayFormatter.presentableForEntity(entity) else {
            return nil
        }

        return presentable
    }

    open func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {
        guard let index = _entityAnnotationMappings?.index(where: { mapping -> Bool in
            return mapping.entity === entity
        }) else {
            return nil
        }
        return _entityAnnotationMappings?[index].annotation
    }

    open func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        MPLRequiresConcreteImplementation()
    }

    public var allAnnotations: [MKAnnotation]? {
        return _entityAnnotationMappings?.map({ return $0.annotation })
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

fileprivate struct EntityAnnotationMapping {
    let entity: MPOLKitEntity
    let annotation: MKAnnotation
}
