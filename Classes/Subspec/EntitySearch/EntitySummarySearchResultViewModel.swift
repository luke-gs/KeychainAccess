//
//  EntityDisplayableSearchResultViewModel.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

open class EntitySummarySearchResultViewModel<T: MPOLKitEntity>: NSObject, SearchResultViewModelable, AggregatedSearchDelegate {
    
    /// Determines behaviour for partial results and "SHOW ALL/SHOW LESS" button on the header.
    ///
    /// - never:    Never limit the results.
    /// - minimum:  Limit the results and show button when entity count > minimum provided.
    /// - always:   Limit the results and always show button.
    public enum ResultLimitBehaviour {
        case never
        case minimum(count: Int)
        case always(count: Int)
        
        public func shouldShowButton(for entityCount: Int) -> Bool {
            switch self {
            case .never:
                return false
            case .minimum(let count):
                return entityCount > count
            case .always(_):
                return true
            }
        }
        
        public var initialCount: Int {
            switch self {
            case .never:
                return 0
            case .minimum(let count), .always(let count):
                return count
            }
        }
    }

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

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    // MARK: - Show all/ Show less properties
    
    public var limitBehaviour: ResultLimitBehaviour = .never

    private var fullResultSectionsShown: [SearchResultSection] = []

    public init(title: String, aggregatedSearch: AggregatedSearch<T>, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.title = title
        self.aggregatedSearch = aggregatedSearch
        self.summaryDisplayFormatter = summaryDisplayFormatter

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
        default:
            if let statusItem = statusItemForSection(section) {
                items.append(statusItem)
            }
        }

        return items
    }

    // MARK: - Subclass can override these methods

    open func headerItemForSection(_ section: SearchResultSection) -> HeaderFormItem {
        let header = HeaderFormItem(text: section.title, style: .collapsible)
            .isExpanded(section.isExpanded)
        
        let updateExpanded = { [weak self, weak header] in
            guard let `self` = self, let header = header else { return }

            if let index = self.results.index(of: section) {
                self.results[index].isExpanded = header.isExpanded
            }
        }

        if section.state == .finished && !section.entities.isEmpty && limitBehaviour.shouldShowButton(for: section.entities.count) {
            let updateHeader = { [weak header, weak self] in
                guard let `self` = self, let header = header else { return }

                if header.isExpanded {
                    let buttonTitle = self.fullResultSectionsShown.contains(section) ? NSLocalizedString("SHOW LESS", comment: "[Search result screen] - Show less results") : NSLocalizedString("SHOW ALL", comment: "[Search result screen] - Show all results")
                    header.actionButton(title: buttonTitle, handler: { (button) in
                        if let index = self.fullResultSectionsShown.index(of: section) {
                            self.fullResultSectionsShown.remove(at: index)
                        } else {
                            self.fullResultSectionsShown.append(section)
                        }
                        self.delegate?.searchResultViewModelDidUpdateResults(self)
                    })
                } else {
                    header.actionButton = nil
                }

                header.reloadItem()
            }

            header.tapHandler = { [weak self, weak header] in
                updateExpanded()
                updateHeader()
            }

            updateHeader()
        } else {
            header.tapHandler = {
                updateExpanded()
            }
        }

        return header
    }

    open func summaryItemsForSection(_ section: SearchResultSection) -> [FormItem] {
        let count = limitBehaviour.initialCount
        let entities = count > 0 && !fullResultSectionsShown.contains(section) ? Array(section.entities.prefix(count)) : section.entities

        return entities.flatMap { entity in
            guard let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }

            let isCompact = style == .list || delegate?.traitCollection.horizontalSizeClass == .compact
            return summary.summaryFormItem(isCompact: isCompact)
                .onSelection { [weak self] _ in
                    guard let `self` = self, let presentable = self.summaryDisplayFormatter.presentableForEntity(entity) else { return }
                    self.delegate?.requestToPresent(presentable)
            }
        }
    }

    open func statusItemForSection(_ section: SearchResultSection) -> FormItem? {
        switch section.state {
        case .failed:
            return CustomFormItem(cellType: SearchResultErrorCell.self, reuseIdentifier: SearchResultErrorCell.defaultReuseIdentifier)
                .onConfigured { (cell) in
                    let cell = cell as! SearchResultErrorCell
                    let error = section.error
                    let message = error?.localizedDescription.ifNotEmpty()
                    cell.titleLabel.text = message ?? NSLocalizedString("Unknown error has occurred.", comment: "[Search result screen] - Unknown error message when error doesn't contain localized description")
                    cell.actionButton.setTitle(NSLocalizedString("Try Again", comment: "[Search result screen] - Try again button"), for: .normal)
                    cell.actionButtonHandler = { [weak self] (cell) in
                        guard let `self` = self, section.error != nil, let index = self.results.index(where: { $0 == section }) else {
                            return
                        }
                        self.aggregatedSearch.retrySearchForResult(result: self.aggregatedSearch.results[index])
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
        case .finished where section.entities.count == 0:
            return CustomFormItem(cellType: SearchResultErrorCell.self, reuseIdentifier: SearchResultErrorCell.defaultReuseIdentifier)
                .onConfigured { (cell) in
                    let cell = cell as! SearchResultErrorCell
                    cell.titleLabel.text = "No records matching your search description have been returned"
                    cell.actionButton.setTitle(NSLocalizedString("New Search", comment: "[Search result screen] - New search button"), for: .normal)
                    cell.actionButtonHandler = { [weak self] (cell) in
                        guard let `self` = self else {  return }
                        self.delegate?.requestToEdit()
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
    
    open func processedResults(from rawResults: [AggregatedResult<T>]) -> [SearchResultSection] {
        
        let processedResults: [SearchResultSection] = rawResults.map { (rawResult) -> SearchResultSection in
            let entities = summarySearchResultsHandler(rawResult.entities)
            return SearchResultSection(title: titleForResult(rawResult),
                                       entities: entities,
                                       isExpanded: true,
                                       state: rawResult.state,
                                       error: rawResult.error)
        }
        
        return processedResults
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
    
    public func titleForResult(_ result: AggregatedResult<T>) -> String {
        switch result.state {
        case .idle:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .searching:
            return String.localizedStringWithFormat(NSLocalizedString("Searching %2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .failed:
            return String.localizedStringWithFormat(NSLocalizedString("%2$@", comment: ""), result.request.source.localizedBadgeTitle.uppercased(with: .current))
        case .finished:
            return String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s) in %2$@", comment: ""), result.entities.count, result.request.source.localizedBadgeTitle.uppercased(with: .current))
        }
    }
}


