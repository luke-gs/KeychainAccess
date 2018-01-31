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

    private var entityAnnotationMappings: [EntityAnnotationMapping] = []

    public var searchType: LocationMapSearchType?

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
            entityAnnotationMappings = mapAnnotations
            allAnnotations = entityAnnotationMappings.map({ return $0.annotation })
        }
    }

    public private(set) var allAnnotations: [MKAnnotation]?

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
        if let annotation = annotation as? ClusterAnnotation {
            let pinView: ClusterAnnotationView
            let identifier = "myBigPileOfPoo"
            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ClusterAnnotationView {
                dequeueView.annotation = annotation
                pinView = dequeueView
            } else {
                pinView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            let summaries = annotation.annotations.flatMap { annotation -> EntitySummaryDisplayable? in
                if let entityAnnotationPair = entityAnnotationMappings.first(where: { $0.annotation === annotation }) {
                    return summaryDisplayFormatter.summaryDisplayForEntity(entityAnnotationPair.entity)
                }
                return nil
            }

            if let highestPriority = summaries.highestPriority() {
                pinView.color = highestPriority.borderColor ?? .gray
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

            if let entityAnnotationPair = entityAnnotationMappings.first(where: { $0.annotation === annotation }),
                let displayable = summaryDisplayFormatter.summaryDisplayForEntity(entityAnnotationPair.entity) as? EntityMapSummaryDisplayable {
                pinView.borderColor = displayable.borderColor ?? .gray
            }

            return pinView
        }

        return nil
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
            return SearchResultSection(title: titleForResult(result),
                                       entities: result.entities,
                                       isExpanded: true,
                                       state: result.state,
                                       error: result.error)
        }
        
        return processedResults
    }

    public func titleForResult(_ result: AggregatedResult<T>) -> String {
        switch result.state {
        case .idle:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .searching:
            return String.localizedStringWithFormat(NSLocalizedString("SEARCHING %2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .finished where result.error != nil:
            fallthrough
        case .failed:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .finished:
            return String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s) in %2$@", comment: ""), result.entities.count, result.request.source.localizedBadgeTitle.uppercased(with: .current))
        }
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
            if let statusItem = statusItemForSection(section) {
                items.append(statusItem)
            }
        }

        return items
    }

    public func itemsForClusteredAnnotations(_ annotations: [MKAnnotation]) -> [FormItem] {
        let entities = annotations.flatMap { annotation -> MPOLKitEntity? in
            return entityAnnotationMappings.first(where: { $0.annotation === annotation })?.entity
        }

        let section = SearchResultSection(title: "\(annotations.count) LOCATIONS SELECTED", entities: entities, isExpanded: false, state: .finished, error: nil)
        return itemsForResultsInSection(section)
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

    open func statusItemForSection(_ section: SearchResultSection) -> FormItem? {
        switch section.state {
        case .finished where section.error != nil || section.entities.count == 0:
            return CustomFormItem(cellType: SearchResultErrorCell.self, reuseIdentifier: SearchResultErrorCell.defaultReuseIdentifier)
                .onConfigured { (cell) in
                    let cell = cell as! SearchResultErrorCell
                    if let error = section.error {
                        let message = error.localizedDescription.ifNotEmpty()
                        cell.titleLabel.text = message ?? NSLocalizedString("Unknown error has occurred.", comment: "[Search result screen] - Unknown error message when error doesn't contain localized description")
                        cell.actionButton.setTitle(NSLocalizedString("Try Again", comment: "[Search result screen] - Try again button"), for: .normal)
                        cell.actionButtonHandler = { [weak self] (cell) in
                            guard let `self` = self, section.error != nil, let index = self.results.index(where: { $0 == section }), let aggregatedSearch = self.aggregatedSearch else {
                                return
                            }
                            aggregatedSearch.retrySearchForResult(result: aggregatedSearch.results[index])
                        }
                    } else {
                        cell.titleLabel.text = "No locations found."
                        cell.actionButton.setTitle(NSLocalizedString("New Search", comment: "[Search result screen] - New search button"), for: .normal)
                        cell.actionButtonHandler = { [weak self] (cell) in
                            guard let `self` = self else {  return }
                            self.delegate?.requestToEdit()
                        }
                    }

                    cell.readMoreButtonHandler = { [weak self] (cell) in
                        guard let `self` = self else {  return }
                        let messageVC = SearchResultMessageViewController(message: cell.titleLabel.text!)
                        let navController = PopoverNavigationController(rootViewController: messageVC)
                        navController.modalPresentationStyle = .formSheet
                        self.delegate?.present(navController, animated: true, completion: nil)
                    }
                }
                .onThemeChanged { (cell, theme) in
                    (cell as! SearchResultErrorCell).apply(theme: theme)
                }
                .height(.fixed(SearchResultErrorCell.contentHeight))
                .separatorStyle(.none)
        case .searching:
            return CustomFormItem(cellType: SearchResultLoadingCell.self, reuseIdentifier: SearchResultLoadingCell.defaultReuseIdentifier)
                .onConfigured { (cell) in
                    let cell = cell as! SearchResultLoadingCell
                    cell.titleLabel.text = NSLocalizedString("Retrieving results", comment: "[Search result screen] - Retrieving results")
                    cell.activityIndicator.play()
                }
                .onThemeChanged { (cell, theme) in
                    (cell as! SearchResultLoadingCell).apply(theme: theme)
                }
                .height(.fixed(SearchResultErrorCell.contentHeight))
                .separatorStyle(.none)
        default: return nil
        }
    }

}

fileprivate struct EntityAnnotationMapping {
    let entity: MPOLKitEntity
    let annotation: MKAnnotation
}
