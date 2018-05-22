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

    func entityDetailSectionsDidAddResults(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel)
    func entityDetailSectionsDidUpdateResults(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel)
    func entityDetailSectionDidSelectRetryDownload(_ entityDetailSectionsViewModel: EntityDetailSectionsViewModel)
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
    public var shouldAutomaticallyFetchFromSubsequentDatasources: Bool = false

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
    private var subsequentFetches: [Fetchable]?
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
        subsequentFetches = subsequentFetches ?? []
        guard var fetchable = matchMaker?.findMatch(for: currentEntity, withInitialSource: initialSource, andDestinationSource: source) else { return }
        subsequentFetches!.append(fetchable)
        fetchable.delegate = self
        fetchable.performFetch()
    }

    public func setSelectedResult(fetchResult: EntityFetchResult) {
        if let recentlyViewed = recentlyViewed, initialSource == selectedSource {
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

    public func entityDetailFetch<T>(_ entityDetailFetch: EntityDetailFetch<T>, didBeginFetch request: EntityDetailFetchRequest<T>) {
        guard let result = entityDetailFetch.results.first(where: { $0.request === request }) else { return }
        if selectedSource == request.source {
            detailSectionsViewControllers?.forEach { $0.loadingManager.state = .loading }
        }

        let source = request.source
        results[source.serverSourceName] = EntityFetchResult(entity: result.entity, state: result.state, error: result.error)

        self.delegate?.entityDetailSectionsDidAddResults(self)
    }

    public func entityDetailFetch<T>(_ entityDetailFetch: EntityDetailFetch<T>, didFinishFetch request: EntityDetailFetchRequest<T>) {
        guard let result = entityDetailFetch.results.first(where: { $0.request === request }) else { return }

        let source = request.source
        let fetchResult = EntityFetchResult(entity: result.entity,
                                            state: result.state,
                                            error: result.error)
        results[source.serverSourceName] = fetchResult

        if source == selectedSource {
            setSelectedResult(fetchResult: fetchResult)
        }

        self.delegate?.entityDetailSectionsDidUpdateResults(self)
    }

    @objc
    fileprivate func newSearchButtonDidSelect(_ button: UIButton) {
        initialSource == selectedSource ? performFetch() : performSubsequentFetch(for: selectedSource)
        delegate?.entityDetailSectionDidSelectRetryDownload(self)
    }

}
