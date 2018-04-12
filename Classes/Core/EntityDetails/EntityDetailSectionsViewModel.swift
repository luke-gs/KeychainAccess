//
//  EntityDetailSectionsViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Fetchable {
    var delegate: EntityDetailFetchDelegate? { get set }
    func performFetch()
}

public protocol EntityDetailSectionsDelegate: class {

    func entityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel)
    func entityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel)
}

public struct EntityFetchResult {
    public var entity: MPOLKitEntity?
    public var state: FetchState = .idle
    public var error: Error?
}

public class EntityDetailSectionsViewModel {

    public var results: [String: EntityFetchResult] = [:]
    public weak var delegate: EntityDetailSectionsDelegate?
    public var selectedSource: EntitySource
    public var recentlyViewed: EntityBucket?
    public var showsActionButton: Bool = true 

    public var detailSectionsViewControllers: [EntityDetailSectionUpdatable]? {
        return detailSectionsDataSources.filter{$0.source == selectedSource}.first?.detailViewControllers
    }

    public var sources: [EntitySource] {
        return detailSectionsDataSources.map{$0.source}
    }

    public var currentEntity: MPOLKitEntity {
        if let result = results[selectedSource.serverSourceName], let entity = result.entity {
            return entity
        } else {
            return (detailSectionsDataSources.filter{$0.source == selectedSource}.first?.entity)!
        }
    }

    public var summary: EntitySummaryDisplayable? {
        return summaryDisplayFormatter.summaryDisplayForEntity(currentEntity)
    }

    private var matchMaker: MatchMaker?
    private var detailSectionsDataSources: [EntityDetailSectionsDataSource]
    private var entityFetch: Fetchable?
    fileprivate let initialSource: EntitySource

    public let summaryDisplayFormatter: EntitySummaryDisplayFormatter

    public init(initialSource: EntitySource, dataSources: [EntityDetailSectionsDataSource], andMatchMaker matchMaker: MatchMaker?, showsActionButton: Bool = true, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.initialSource = initialSource
        self.showsActionButton = showsActionButton
        self.selectedSource = initialSource
        self.detailSectionsDataSources = dataSources
        self.matchMaker = matchMaker
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }

    public func performFetch() {
        entityFetch = detailSectionsDataSources.filter{$0.source == selectedSource}.first?.fetchModel()
        entityFetch?.delegate = self
        entityFetch?.performFetch()
    }

    public func performSubsequentFetch(for source: EntitySource) {
        entityFetch = matchMaker?.findMatch(for: currentEntity, withInitialSource: initialSource, andDestinationSource: selectedSource)
        entityFetch?.delegate = self
        entityFetch?.performFetch()
    }

    public func setSelectedResult(fetchResult: EntityFetchResult) {
        if let recentlyViewed = recentlyViewed {
            if let entity = fetchResult.entity, fetchResult.error == nil {
                if recentlyViewed.contains(entity) {
                    recentlyViewed.remove(entity)
                }
                recentlyViewed.add(entity)
            }
        }

        detailSectionsViewControllers?.forEach {
            // If the error is nil, give the ViewControllers the retrieved entity
            guard let error = fetchResult.error else {
                $0.genericEntity = fetchResult.entity
                return
            }

            // ... Otherwise display the error
            $0.genericEntity = nil

            let noContentView = $0.loadingManager.noContentView
            noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
            noContentView.imageView.tintColor = #colorLiteral(red: 0.6044161711, green: 0.6313971979, blue: 0.6581829122, alpha: 0.6420554578)

            noContentView.titleLabel.text = NSLocalizedString(error.localizedDescription, comment: "")
            noContentView.subtitleLabel.text = nil
            let actionButton = noContentView.actionButton
            actionButton.setTitle(NSLocalizedString("Retry Download", comment: ""), for: .normal)
            actionButton.addTarget(self, action: #selector(newSearchButtonDidSelect(_:)), for: .primaryActionTriggered)
        }
    }

}

extension EntityDetailSectionsViewModel: EntityDetailFetchDelegate {

    public func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didBeginFetch request: EntityDetailFetchRequest<T>) {

        detailSectionsViewControllers?.forEach { $0.loadingManager.state = .loading }

        guard let result = EntityDetailFetch.results.first(where: { $0.request === request }) else {
            return
        }

        let source = request.source

        results[source.serverSourceName] = EntityFetchResult(entity: result.entity, state: result.state, error: result.error)

        self.delegate?.entityDetailSectionsDidUpdateResults(self)
    }

    public func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didFinishFetch request: EntityDetailFetchRequest<T>) {

        guard let result = EntityDetailFetch.results.first(where: { $0.request === request }) else {
            return
        }

        let source = request.source
        let fetchResult = EntityFetchResult(entity: result.entity,
                                            state: result.state,
                                            error: result.error)
        results[source.serverSourceName] = fetchResult

        if source == selectedSource {
            setSelectedResult(fetchResult: fetchResult)
        }

        self.delegate?.entityDetailSectionsDidUpdateResults(self)

        if let entity = fetchResult.entity {
            if let entityManager = self.recentlyViewed?.entityManager {
                entityManager.addEntity(entity)
            }
        }
    }

    @objc
    fileprivate func newSearchButtonDidSelect(_ button: UIButton) {
        initialSource == selectedSource ? performFetch() : performSubsequentFetch(for: selectedSource)
        delegate?.entityDetailSectionDidSelectRetryDownload(self)
    }

}
