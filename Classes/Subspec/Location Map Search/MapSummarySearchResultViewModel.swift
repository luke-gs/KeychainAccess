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

    public let title: String

    public var status: SearchState? {
        return aggregatedSearch?.state
    }

    public let searchStrategy: LocationSearchModelStrategy

    private var _entityAnnotationMappings: [EntityAnnotationMapping]? = []

    public var searchType: LocationMapSearchType!

    public weak var delegate: (MapResultViewModelDelegate & SearchResultMapViewController)?
    
    public private(set) var aggregatedSearch: AggregatedSearch<T>?
    
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

    public init(searchStrategy: LocationSearchModelStrategy, title: String = "", aggregatedSearch: AggregatedSearch<T>? = nil, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {

        self.searchStrategy = searchStrategy
        self.title = title
        self.aggregatedSearch = aggregatedSearch
        self.summaryDisplayFormatter = summaryDisplayFormatter

        aggregatedSearch?.delegate = self
        aggregatedSearch?.performSearch()
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
        guard let currentAggregatedSearch = self.aggregatedSearch else { return }
        self.results = self.processedResults(from: currentAggregatedSearch.results)
        delegate?.mapResultViewModelDidUpdateResults(self)
    }
    
    public func aggregatedSearch<T>(_ aggregatedSearch: AggregatedSearch<T>, didEndSearch request: AggregatedSearchRequest<T>) {
        guard let currentAggregatedSearch = self.aggregatedSearch else { return }
        self.results = self.processedResults(from: currentAggregatedSearch.results)
        delegate?.mapResultViewModelDidUpdateResults(self)
    }
    
    private func processedResults(from rawResults: [AggregatedResult<T>]) -> [SearchResultSection] {
        let processedResults: [SearchResultSection] = rawResults.map { (result) -> SearchResultSection in
            return SearchResultSection(title: String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s)", comment: ""), result.entities.count),
                                       entities: result.entities,
                                       isExpanded: true,
                                       state: result.state,
                                       error: result.error)
        }
        
        return processedResults
    }

    // NEW STUFFS

    // MARK: - SearchResultViewModelable

    public func itemsForResultsInSection(_ section: SearchResultSection) -> [FormItem] {
        var items = [FormItem]()

        items.append(headerItemForSection(section))

        switch section.state {
        case .finished where section.entities.count > 0:
            items += summaryItemsForSection(section)
        default:
            break
        }

        return items
    }

    // MARK: - Subclass can override these methods

    open func headerItemForSection(_ section: SearchResultSection) -> HeaderFormItem {
        return HeaderFormItem(text: section.title)
    }

    open func summaryItemsForSection(_ section: SearchResultSection) -> [FormItem] {
        return section.entities.flatMap { entity in
            guard let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return nil }

            return summary.summaryListFormItem()
                .onSelection { [weak self] _ in
                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                    self.delegate?.requestToPresent(presentable)
            }
        }
    }
}

fileprivate struct EntityAnnotationMapping {
    let entity: MPOLKitEntity
    let annotation: MKAnnotation
}
