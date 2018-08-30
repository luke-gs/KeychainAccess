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

public enum MapSummaryAnnotationViewIdentifier: String {
    case cluster = "MapSummaryAnnotationViewIdentifierCluster"
    case single  = "MapSummaryAnnotationViewIdentifierSingle"
}

open class MapSummarySearchResultViewModel<T: MPOLKitEntity>: MapResultViewModelable, AggregatedSearchDelegate {

    public let title: String

    public var status: SearchState? {
        return aggregatedSearch?.state
    }

    public let searchStrategy: LocationSearchModelStrategy

    public var searchType: LocationMapSearchType?

    public weak var delegate: (MapResultViewModelDelegate & SearchResultMapViewController)?
    
    public private(set) var aggregatedSearch: AggregatedSearch<T>?
    
    public var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()
    
    public var results: [SearchResultSection]  = [] {
        didSet {
            var itemsMap = [MPOLKitEntity: FormItem]()
            resultAnnotations = results.flatMap({ section -> [MKAnnotation] in
                for (entity, item) in zip(section.entities, self.summaryItemsForSection(section)) {
                    itemsMap[entity] = item
                }

                return section.entities.compactMap { self.mapAnnotation(for: $0) }
            })
            self.itemsMap = itemsMap
        }
    }

    public private(set) var resultAnnotations: [MKAnnotation]?
    
    public var searchOriginAnnotation: SearchOriginAnnotation? {
        let originAnnotation = ColoredPinAnnotation()
        originAnnotation.pinTintColor = .brightBlue
        return originAnnotation
    }

    private var itemsMap: [MPOLKitEntity: FormItem] = [:]

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))

    public init(searchStrategy: LocationSearchModelStrategy, title: String = "", aggregatedSearch: AggregatedSearch<T>? = nil, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {

        self.searchStrategy = searchStrategy
        self.title = title
        self.aggregatedSearch = aggregatedSearch
        self.summaryDisplayFormatter = summaryDisplayFormatter

        aggregatedSearch?.delegate = self
        aggregatedSearch?.performSearch()
    }

    // MARK: - Map related

    open func mapAnnotation(for entity: MPOLKitEntity) -> EntityAnnotation? {
        guard let displayable = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return nil }
        guard let coordinate = displayable.coordinate else { return nil }

        let annotation = EntityAnnotation(entity: entity)
        annotation.coordinate = coordinate
        annotation.title = displayable.title
        return annotation
    }

    open func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let pinView: MPOLClusterAnnotationView
            let identifier = MapSummaryAnnotationViewIdentifier.cluster.rawValue
            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MPOLClusterAnnotationView {
                dequeueView.annotation = annotation
                pinView = dequeueView
            } else {
                pinView = MPOLClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            let summaries = annotation.annotations.compactMap { annotation -> EntitySummaryDisplayable? in
                if let annotation = annotation as? EntityAnnotation {
                    return summaryDisplayFormatter.summaryDisplayForEntity(annotation.entity)
                }
                return nil
            }

            if let highestPriority = summaries.highestPriority() {
                pinView.color = highestPriority.borderColor ?? .gray
            }

            return pinView
        } else if let annotation = annotation as? EntityAnnotation {
            let pinView: LocationAnnotationView
            let identifier = MapSummaryAnnotationViewIdentifier.single.rawValue
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocationAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                pinView = LocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            if let displayable = summaryDisplayFormatter.summaryDisplayForEntity(annotation.entity) as? EntityMapSummaryDisplayable {
                pinView.borderColor = displayable.borderColor ?? .gray
            }

            return pinView
        } else if let annotation = annotation as? ColoredPinAnnotation {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MapSummaryAnnotationViewIdentifier.single.rawValue)
            pinView.pinTintColor = annotation.pinTintColor
            return pinView
        }

        return nil
    }

    @objc private func annotationTapped(_ recognizer: UITapGestureRecognizer) {
        guard let annotationView = recognizer.view as? LocationAnnotationView, let annotation = annotationView.annotation as? EntityAnnotation else { return }

        if let presentable = self.summaryDisplayFormatter.presentableForEntity(annotation.entity) {
            delegate?.requestToPresent(presentable)
        }
    }

    public func annotationViewDidSelect(annotationView: MKAnnotationView, in mapView: MKMapView) {
        guard let annotationView = annotationView as? LocationAnnotationView else { return }
        annotationView.addGestureRecognizer(tapGestureRecognizer)

        if let entity = (annotationView.annotation as? EntityAnnotation)?.entity, let item = itemsMap[entity] {
            delegate?.selectItem(item)
        }
    }

    public func annotationViewDidDeselect(annotationView: MKAnnotationView, in mapView: MKMapView) {
        guard let annotationView = annotationView as? LocationAnnotationView else { return }
        annotationView.removeGestureRecognizer(tapGestureRecognizer)

        if let entity = (annotationView.annotation as? EntityAnnotation)?.entity, let item = itemsMap[entity] {
            delegate?.deselectItem(item)
        }
    }

    public func userLocationDidUpdate(_ userLocation: MKUserLocation, in mapView: MKMapView) {
        guard let userLocation = userLocation.location else { return }

        itemsMap.forEach { (entity, item) in
            guard let item = item as? SummaryListFormItem, let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return }

            if let coordinate = summary.coordinate {
                let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                travelEstimationPlugin.calculateDistance(from: userLocation, to: destinationLocation).done { [weak item] text -> Void in
                    item?.subtitle(text).reloadItem()
                }.catch { [weak item] (error) in
                    item?.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
                }
            } else {
                item.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
            }
        }
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
                                       error: result.error,
                                       source: result.request.source)
        }
        
        return processedResults
    }

    public func titleForResult(_ result: AggregatedResult<T>) -> String {
        switch result.state {
        case .idle:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle)
        case .searching:
            return String.localizedStringWithFormat(NSLocalizedString("Searching %2$@", comment: ""), result.request.source.localizedBadgeTitle)
        case .finished where result.error != nil:
            fallthrough
        case .failed:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle)
        case .finished:
            return String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s)", comment: ""), result.entities.count)
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
        let entities = annotations.compactMap { annotation -> MPOLKitEntity? in
            return (annotation as? EntityAnnotation)?.entity
        }

        let title = String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s) Selected", comment: ""), annotations.count)
        let section = SearchResultSection(title: title, entities: entities, isExpanded: false, state: .finished, error: nil)
        return itemsForResultsInSection(section)
    }

    // MARK: - Subclass can override these methods

    open func headerItemForSection(_ section: SearchResultSection) -> LargeTextHeaderFormItem {
        let string = StringSizing(string: section.title, numberOfLines: 2)
        return LargeTextHeaderFormItem(text: string)
            .separatorColor(.clear)
    }

    open func summaryItemsForSection(_ section: SearchResultSection) -> [FormItem] {
        let userLocation = delegate?.mapView?.userLocation.location

        return section.entities.compactMap { entity in
            if let existingItem = self.itemsMap[entity] {
                return existingItem
            }

            guard let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return nil }

            let summaryItem = summary.summaryListFormItem()
                .selectionStyle(.tableView)
                .accessory(nil)
                .separatorStyle(.indented)
                .subtitle(NSLocalizedString("Unknown", comment: ""))
                .onSelection { [weak self] _ in
                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                    self.delegate?.requestToPresent(presentable)
                }

            if let userLocation = userLocation {
                updateDistanceFor(summaryItem, andEntity: entity, fromLocation: userLocation)
            }

            return summaryItem
        }
    }

    private func updateDistanceFor(_ item: SummaryListFormItem, andEntity entity: MPOLKitEntity, fromLocation location: CLLocation) {
        guard let summary = self.summaryDisplayFormatter.summaryDisplayForEntity(entity) as? EntityMapSummaryDisplayable else { return }

        if let coordinate = summary.coordinate {
            let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            travelEstimationPlugin.calculateDistance(from: location, to: destinationLocation).done { [weak item] text -> Void in
                item?.subtitle(text).reloadItem()
            }.catch { [weak item] (error) in
                item?.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
            }
        } else {
            item.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
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

public class EntityAnnotation: MKPointAnnotation {

    public var entity: MPOLKitEntity

    public init(entity: MPOLKitEntity) {
        self.entity = entity
    }

}
