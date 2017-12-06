//
//  EntityDisplayableSearchResultViewModel.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public class EntitySummarySearchResultViewModel<T: MPOLKitEntity, Decorator: EntitySummaryDisplayable>: NSObject, SearchResultViewModelable, AggregatedSearchDelegate {

    public let title: String
    
    public var status: SearchState? {
        return aggregatedSearch.state
    }
    
    public var style: SearchResultStyle = .grid
    
    public var results: [SearchResultSection] = []
    
    public var additionalBarButtonItems: [UIBarButtonItem]? = nil
    
    public weak var delegate: (SearchResultViewModelDelegate & SearchResultsListViewController)?
    
    public var summarySearchResultsHandler: ((_ entities: [T]) -> [T]) = { return $0 }
    
    public let aggregatedSearch: AggregatedSearch<T>

    public init(title: String, aggregatedSearch: AggregatedSearch<T>) {
        self.title = title
        self.aggregatedSearch = aggregatedSearch

        super.init()
        
        aggregatedSearch.delegate = self
        aggregatedSearch.performSearch()
    }
    
    // MARK: - SearchResultViewModelable

    public func itemsForResultsInSection(_ section: SearchResultSection) -> [FormItem] {
        var items = [FormItem]()

        items.append(headerItemForSection(section))

        switch section.state {
        case .finished where section.entities.count > 0:
            items += summaryItemsForSection(section)
            items += summaryItemsForSection(section)
            items += summaryItemsForSection(section)
            items += summaryItemsForSection(section)
            items += summaryItemsForSection(section)
            items += summaryItemsForSection(section)
        default:
            if let statusItem = statusItemForSection(section) {
                items.append(statusItem)
            }
        }

        return items
    }

    // MARK: - Subclass can override these methods

    open func headerItemForSection(_ section: SearchResultSection) -> HeaderFormItem {
        return HeaderFormItem(text: section.title, style: .collapsible)
    }

    open func summaryItemsForSection(_ section: SearchResultSection) -> [FormItem] {
        return section.entities.map {
            let summary = Decorator($0)

            if style == .list || delegate?.traitCollection.horizontalSizeClass == .compact {
                let subtitleComponents = [summary.detail1, summary.detail2].flatMap({$0})

                return SummaryListFormItem()
                    .category(summary.category)
                    .title(summary.title)
                    .subtitle(subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : "))
                    .badge(summary.badge)
                    .badgeColor(summary.iconColor)
                    .borderColor(summary.borderColor)
                    .image(summary.thumbnail(ofSize: .small))

            } else {
                return SummaryThumbnailFormItem()
                    .style(.hero)
                    .category(summary.category)
                    .title(summary.title)
                    .subtitle(summary.detail1)
                    .detail(summary.detail2)
                    .badge(summary.badge)
                    .badgeColor(summary.iconColor)
                    .borderColor(summary.borderColor)
                    .image(summary.thumbnail(ofSize: .large))
            }
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
                            guard let `self` = self, section.error != nil, let index = self.results.index(where: { $0 == section }) else {
                                return
                            }
                            self.aggregatedSearch.retrySearchForResult(result: self.aggregatedSearch.results[index])
                        }
                    } else {
                        cell.titleLabel.text = "No records matching your search description have been returned"
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

    // MARK: - AggregatedSearchDelegate
    
    public func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didBeginSearch request: AggregatedSearchRequest<U>) {
        self.results = self.processedResults(from: self.aggregatedSearch.results)
        delegate?.searchResultViewModelDidUpdateResults(self)
    }
    
    public func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didEndSearch request: AggregatedSearchRequest<U>) {
        self.results = self.processedResults(from: self.aggregatedSearch.results)
        delegate?.searchResultViewModelDidUpdateResults(self)
    }
    
    
    // MARK: - Private

    private func entityStyle(for style: SearchResultStyle) -> EntityCollectionViewCell.Style {
        return style == .grid ? .hero : .detail
    }
    
    private func processedResults(from rawResults: [AggregatedResult<T>]) -> [SearchResultSection] {
        
        let processedResults: [SearchResultSection] = rawResults.map { (rawResult) -> SearchResultSection in
            let entities = summarySearchResultsHandler(rawResult.entities)
            return SearchResultSection(title: rawResult.titleForCurrentState(),
                                       entities: entities,
                                       isExpanded: true,
                                       state: rawResult.state,
                                       error: rawResult.error)
        }
        
        return processedResults
    }
}

private extension AggregatedResult  {
    func titleForCurrentState() -> String {
        switch state {
        case .idle:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), request.source.localizedBadgeTitle.uppercased(with: .current))
        case .searching:
            return String.localizedStringWithFormat(NSLocalizedString("Searching %2$@", comment: ""), request.source.localizedBadgeTitle.uppercased(with: .current))
        case .finished where error != nil:
            fallthrough
        case .failed:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), request.source.localizedBadgeTitle.uppercased(with: .current))
        case .finished:
            return String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s) in %2$@", comment: ""), entities.count, request.source.localizedBadgeTitle.uppercased(with: .current))
        }
    }
}


