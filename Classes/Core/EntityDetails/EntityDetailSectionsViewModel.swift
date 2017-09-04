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
    public var result: MPOLKitEntity?
    public var state: FetchState = .idle
    public var error: Error?
}

public class EntityDetailSectionsViewModel {

    public var sources: [EntitySource]!

    public var entityFetch: Fetchable?

    public var detailSectionsDataSource: [EntityDetailSectionsDataSource] = []

    public var detailSectionsViewControllers: [EntityDetailSectionUpdatable]?

    public weak var delegate: EntityDetailSectionsDelegate?

    public var entity: MPOLKitEntity

    public var results: [String: EntityFetchResult] = [:]

    public init(sources: [EntitySource]? = [], entity: MPOLKitEntity) {

        self.sources = sources
        self.entity = entity

        let dataSource = detailSectionsDataSource.first {
            $0.localizedDisplayName == String(describing: type(of: entity))
        }

        entityFetch = dataSource?.fetchModel(for: entity, sources: self.sources)
        entityFetch?.delegate = self
        detailSectionsViewControllers = dataSource?.detailViewControllers
    }

    public func performFetch() {
        entityFetch?.performFetch()
    }

    public func dataSource(at index: Int) -> EntitySource {
        return sources[index]
    }

}

extension EntityDetailSectionsViewModel: EntityDetailFetchDelegate {

    public func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didBeginFetch request: EntityDetailFetchRequest<T>) {

        detailSectionsViewControllers?.forEach { $0.loadingManager.state = .loading }

        guard let result = EntityDetailFetch.results.first(where: { $0.request === request }) else {
            return
        }

        let source = request.source

        results[source.serverSourceName] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)

        self.delegate?.EntityDetailSectionsDidUpdateResults(self)
    }

    public func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didFinishFetch request: EntityDetailFetchRequest<T>) {

        guard let result = EntityDetailFetch.results.first(where: { $0.request === request }) else {
            return
        }

        let source = request.source

        results[source.serverSourceName] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)

        if let error = result.error {
            detailSectionsViewControllers?.forEach {
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
        } else {
            detailSectionsViewControllers?.forEach {
                $0.genericEntity = (result.entity)
            }
        }
        self.delegate?.EntityDetailSectionsDidUpdateResults(self)
    }

    @objc
    private func newSearchButtonDidSelect(_ button: UIButton) {
        delegate?.EntityDetailSectionDidSelectRetryDownload(self)
    }

}
