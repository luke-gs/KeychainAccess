//
//  FancyEntityDatasourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol FancyEntityDetailsDatasourceViewModelDelegate: class {
    func fancyEntityDetailsDatasourceViewModelDidBeginFetch(_ viewModel: FancyEntityDetailsDatasourceViewModel)
    func fancyEntityDetailsDatasourceViewModel(_ viewmodel: FancyEntityDetailsDatasourceViewModel, didEndFetchWith state: FancyEntityDetailsDatasourceViewModel.State)
}

public protocol EntityRetrieveStrategy {
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>?
}

public enum EntityState {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

public protocol FancyEntityDetailsDataSource {
    var viewControllers: [UIViewController] { get set }
    var source: EntitySource { get }
}

open class FancyEntityDetailsDatasourceViewModel {

    public enum State {
        case empty
        case loading
        case result([EntityState])
        case error(Error)
    }

    public var datasource: FancyEntityDetailsDataSource
    public weak var delegate: FancyEntityDetailsDatasourceViewModelDelegate?

    private(set) var state: State = .empty
    private let strategy: EntityRetrieveStrategy

    public init(datasource: FancyEntityDetailsDataSource, strategy: EntityRetrieveStrategy) {
        self.datasource = datasource
        self.strategy = strategy
    }

    public func retrieve(for entity: MPOLKitEntity) {
        state = .loading
        delegate?.fancyEntityDetailsDatasourceViewModelDidBeginFetch(self)
        self.updateViewControllers()

        strategy.retrieveUsingReferenceEntity(entity)?
            .done { [weak self] states in
                guard let `self` = self else { return }
                self.state = .result(states)
                self.updateViewControllers()
                self.delegate?.fancyEntityDetailsDatasourceViewModel(self, didEndFetchWith: .result(states))
            }.catch { [weak self] error in
                guard let `self` = self else { return }
                self.state = .error(error)
                self.updateViewControllers()
                self.delegate?.fancyEntityDetailsDatasourceViewModel(self, didEndFetchWith: .error(error))
        }
    }

    private func updateViewControllers() {
        let viewControllersToUpdate: [EntityDetailSectionUpdatable] = datasource.viewControllers.compactMap{$0 as? EntityDetailSectionUpdatable}

        switch state {
        case .empty:
            viewControllersToUpdate.forEach{$0.loadingManager.state = .noContent}
        case .loading:
            viewControllersToUpdate.forEach{$0.loadingManager.state = .loading}
        case .result(let states):
            if states.count == 1 {
                let entityState = states.first!
                switch entityState {
                case .summary(let entity), .detail(let entity):
                    viewControllersToUpdate.forEach{$0.genericEntity = entity}
                    viewControllersToUpdate.forEach{$0.loadingManager.state = .loaded}
                }
            } else {
                viewControllersToUpdate.forEach{$0.loadingManager.state = .noContent}
            }
        case .error:
            viewControllersToUpdate.forEach{$0.loadingManager.state = .error}
        }
    }
}


