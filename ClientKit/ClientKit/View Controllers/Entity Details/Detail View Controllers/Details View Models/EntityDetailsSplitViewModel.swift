//
//  EntityDetailsSplitViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public protocol Fetchable {
    weak var delegate: EntityDetailsFetchDelegate? { get set }
    func performFetch()
}

public protocol EntityDetailsSectionsDelegate: class {
    
    func entityDetailsSectionsDidUpdateResults(_ entityDetailsSectionsViewModel: EntityDetailsSectionsViewModel)
    func entityDetailsSectionDidSelectRetryDownload(_ entityDetailsSectionsViewModel: EntityDetailsSectionsViewModel)
}

public struct EntityFetchResult {
    public var result: MPOLKitEntity?
    public var state: FetchState = .idle
    public var error: Error?
}

public class EntityDetailsSectionsViewModel {
    
    public var sources: [MPOLSource]!
    
    public var entityFetch: Fetchable?
    
    public var detailsSectionsDataSource: [EntityDetailSectionsDataSource] = [PersonDetailsSectionsDataSource(), VehicleDetailsSectionsDataSource()]
    
    public var detailsSectionsViewControllers: [EntityDetailCollectionViewController]?
    
    public weak var delegate: EntityDetailsSectionsDelegate?
    
    public var entity: MPOLKitEntity
    
    public var results: [MPOLSource: EntityFetchResult] = [:]
    
    public init(sources: [MPOLSource]? = [.mpol], entity: MPOLKitEntity) {
        
        self.sources = sources
        self.entity = entity

        let dataSource = detailsSectionsDataSource.first {
            $0.localizedDisplayName == String(describing: type(of: entity))
        }
        
        entityFetch = dataSource?.fetchModel(for: entity as! Entity, sources: self.sources)
        entityFetch?.delegate = self
        detailsSectionsViewControllers = dataSource?.detailsViewControllers
    }
    
    public func performFetch() {
        entityFetch?.performFetch()
    }
    
    public func dataSource(at index: Int) -> MPOLSource {
        return sources[index]
    }
}

extension EntityDetailsSectionsViewModel: EntityDetailsFetchDelegate {
    
    public func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didBeginFetch request: EntityDetailsFetchRequest<T>) {
        
        detailsSectionsViewControllers?.forEach { $0.loadingManager.state = .loading }

        guard let result = entityDetailsFetch.results.first(where: { $0.request === request } ) else {
            return
        }
        
        let source = request.source as! MPOLSource
        
        results[source] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)
        
        self.delegate?.entityDetailsSectionsDidUpdateResults(self)
    }
    
    public func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didFinishFetch request: EntityDetailsFetchRequest<T>) {
        
        guard let result = entityDetailsFetch.results.first(where: { $0.request === request } ) else {
            return
        }
        
        let source = request.source as! MPOLSource
        
        results[source] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)
        
        if let error = result.error {
            if source == sources.first! {
                detailsSectionsViewControllers?.forEach {
                    $0.entity = nil
                    
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
        } else {
            if source == sources.first! {
                detailsSectionsViewControllers?.forEach {
                    $0.entity = (result.entity as? Entity)
                }
            }
        }
        self.delegate?.entityDetailsSectionsDidUpdateResults(self)
    }
    
    @objc
    private func newSearchButtonDidSelect(_ button: UIButton) {
        delegate?.entityDetailsSectionDidSelectRetryDownload(self)
    }
}

