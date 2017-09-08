//
//  EntityDisplayableSearchResultViewModel.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public class EntitySummarySearchResultViewModel<T: MPOLKitEntity>: NSObject, SearchResultViewModelable, AggregatedSearchDelegate where T: EntitySummaryDisplayable {
    
    private enum CellIdentifier: String {
        case alertCellIdentifier
        case gridCellIdentifier
        case listCellIdentifier
    }
    
    public let title: String
    
    public var status: SearchState? {
        return aggregatedSearch.state
    }
    
    public var style: SearchResultStyle = .grid
    
    public var results: [SearchResultSection] = []
    
    public weak var delegate: SearchResultViewModelDelegate?
    
    public let aggregatedSearch: AggregatedSearch<T>
    
    public init(title: String, aggregatedSearch: AggregatedSearch<T>) {
        self.title = title
        self.aggregatedSearch = aggregatedSearch
        
        super.init()
        
        aggregatedSearch.delegate = self
        aggregatedSearch.performSearch()
    }
    
    // MARK: - SearchResultViewModelable
    
    public func registerCells(for collectionView: UICollectionView) {
        collectionView.register(EntityCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.alertCellIdentifier.rawValue)
        collectionView.register(EntityCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.gridCellIdentifier.rawValue)
        collectionView.register(EntityListCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.listCellIdentifier.rawValue)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, for traitCollection: UITraitCollection) ->
        UICollectionViewCell {
            
            let result = results[indexPath.section]
            let entity = result.entities[indexPath.item]
            
            if style == .list || traitCollection.horizontalSizeClass == .compact {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.listCellIdentifier.rawValue, for: indexPath) as! EntityListCollectionViewCell
                cell.decorate(with: entity as! EntitySummaryDisplayable)
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.gridCellIdentifier.rawValue, for: indexPath) as! EntityCollectionViewCell
                
                cell.style = self.entityStyle(for: style)
                cell.decorate(with: entity as! EntitySummaryDisplayable)
                
                return cell
            }
    }
    
    public func collectionView(_ collectionView: UICollectionView, minimumContentWidthForItemAt indexPath: IndexPath, for traitCollection: UITraitCollection) -> CGFloat {
        
        if style == .grid && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: entityStyle(for: style))
        }
        
        return collectionView.bounds.width
    }
    
    public func collectionView(_ collectionView: UICollectionView, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        
        if style == .grid && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: entityStyle(for: style), compatibleWith: traitCollection) - 12.0
        }
        
        return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
    }
    
    public func retry(section: Int) {
        guard results[section].error != nil else {
            return
        }
        
        aggregatedSearch.retrySearchForResult(result: aggregatedSearch.results[section])
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
            return SearchResultSection(title: rawResult.titleForCurrentState(),
                                       entities: rawResult.entities,
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


