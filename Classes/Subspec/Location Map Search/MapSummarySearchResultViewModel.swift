//
//  MapSummarySearchResultViewModel.swift
//  Pods
//
//  Created by RUI WANG on 7/9/17.
//
//

import Foundation
import MapKit
import PromiseKit
import Cluster

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

    // MARK: - Map related

    open func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {
        guard let displayable = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return nil }
        guard let coordinate = displayable.coordinate else { return nil }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = displayable.title
        return annotation
    }

    open func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        if annotation is ClusterAnnotation {
            let pinView: ClusterAnnotationView
            let identifier = "myBigPileOfPoo"
            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ClusterAnnotationView {
                dequeueView.annotation = annotation
                pinView = dequeueView
            } else {
                pinView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return pinView
        } else if annotation is MKPointAnnotation {
            let pinView: LocationAnnotationView
            let identifier = "myLittlePileOfPoo"
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            return pinView
        }

        return nil
    }

    open func annotationViewDidSelect(for annotationView: MKAnnotationView, in mapView: MKMapView) { }

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
        let userLocation = delegate?.mapView?.userLocation.location

        return section.entities.flatMap { entity in
            guard let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return nil }

            let summaryItem = summary.summaryListFormItem()
                .accessory(nil)
                .onSelection { [weak self] _ in
                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                    self.delegate?.requestToPresent(presentable)
                }

            if let userLocation = userLocation, let coordinate = summary.coordinate {
                summaryItem.subtitle = NSLocalizedString("Calculating", comment: "")
                let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                travelEstimationPlugin.calculateDistance(from: userLocation, to: destinationLocation).then { [weak summaryItem] text -> Void in
                    summaryItem?.subtitle(text).reloadItem()
                }.catch { [weak summaryItem] (error) in
                    summaryItem?.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
                }
            } else {
                summaryItem.subtitle = NSLocalizedString("Unknown", comment: "")
            }

            return summaryItem
        }
    }

}

fileprivate struct EntityAnnotationMapping {
    let entity: MPOLKitEntity
    let annotation: MKAnnotation
}
