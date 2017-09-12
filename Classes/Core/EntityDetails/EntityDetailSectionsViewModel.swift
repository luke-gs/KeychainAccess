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
    weak var delegate: EntityDetailFetchDelegate? { get set }
    func performFetch()
}

public protocol EntityDetailSectionsDelegate: class {

    func EntityDetailSectionsDidUpdateResults(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel)
    func EntityDetailSectionDidSelectRetryDownload(_ EntityDetailSectionsViewModel: EntityDetailSectionsViewModel)
}

public struct EntityFetchResult {
    public var entity: MPOLKitEntity?
    public var state: FetchState = .idle
    public var error: Error?
}

public class EntityDetailSectionsViewModel {

    public var sources: [EntitySource] {
        return detailSectionsDataSource.sources
    }

    public var currentEntity: MPOLKitEntity {
        if let result = results[selectedSource.serverSourceName], let entity = result.entity {
            return entity
        } else {
            return detailSectionsDataSource.baseEntity
        }
    }

    public var selectedSource: EntitySource

    private var entityFetch: Fetchable?

    public var detailSectionsDataSource: EntityDetailSectionsDataSource

    public var detailSectionsViewControllers: [EntityDetailSectionUpdatable]?

    public weak var delegate: EntityDetailSectionsDelegate?

    public var results: [String: EntityFetchResult] = [:]

    public init(dataSource: EntityDetailSectionsDataSource) {

        selectedSource = dataSource.initialSource
        self.detailSectionsDataSource = dataSource

        entityFetch = dataSource.fetchModel(for: dataSource.baseEntity, sources: self.sources)
        entityFetch?.delegate = self
        detailSectionsViewControllers = dataSource.detailViewControllers
    }

    public func performFetch() {
        entityFetch?.performFetch()
    }

    public func setSelectedResult(fetchResult: EntityFetchResult) {
        detailSectionsViewControllers?.forEach {
            // If the error is nil, give the ViewControllers the retrieved entity
            guard let error = fetchResult.error else {
                $0.genericEntity = (fetchResult.entity)
                return
            }

            // ... Otherwise display the error
            $0.genericEntity = nil

            let noContentView = $0.loadingManager.noContentView
            noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
            noContentView.imageView.tintColor = #colorLiteral(red: 0.6044161711, green: 0.6313971979, blue: 0.6581829122, alpha: 0.6420554578)

            noContentView.titleLabel.text = NSLocalizedString(error.localizedDescription, comment: "")
            let actionButton = noContentView.actionButton
            actionButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
            actionButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
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

        self.delegate?.EntityDetailSectionsDidUpdateResults(self)
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

        self.delegate?.EntityDetailSectionsDidUpdateResults(self)
    }

    @objc
    fileprivate func newSearchButtonDidSelect(_ button: UIButton) {
        performFetch()
        delegate?.EntityDetailSectionDidSelectRetryDownload(self)
    }

}
