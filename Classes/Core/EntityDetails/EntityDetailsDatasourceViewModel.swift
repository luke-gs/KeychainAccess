//
//  EntityDatasourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Defines an object that has an Entity and LoadingStateManager so it could be notified about the update status
/// of the new data.
public protocol EntityDetailSectionUpdatable: class {

    /// The entity
    var genericEntity: MPOLKitEntity? { get set }

    /// The loading manager
    var loadingManager: LoadingStateManager { get }
}

public struct EntityDetailMatch {
    public var sourceToMatch: EntitySource
    public var shouldMatchAutomatically: Bool

    public init(sourceToMatch: EntitySource, shouldMatchAutomatically: Bool = true) {
        self.sourceToMatch = sourceToMatch
        self.shouldMatchAutomatically = shouldMatchAutomatically
    }
}

public protocol EntityDetailsDatasourceViewModelDelegate: class {
    func fancyEntityDetailsDatasourceViewModelDidBeginFetch(_ viewModel: EntityDetailsDatasourceViewModel)
    func fancyEntityDetailsDatasourceViewModel(_ viewmodel: EntityDetailsDatasourceViewModel, didEndFetchWith state: EntityDetailsDatasourceViewModel.State)
}

public protocol EntityRetrieveStrategy {
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>?
}

public enum EntityState: Equatable {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

public func == (lhs: EntityState, rhs: EntityState) -> Bool {
    switch (lhs, rhs) {
    case (.summary(let lhsEntity), .detail(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.detail(let lhsEntity), .summary(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.detail(let lhsEntity), .detail(let rhsEntity)):
        return lhsEntity == rhsEntity
    case (.summary(let lhsEntity), .summary(let rhsEntity)):
        return lhsEntity == rhsEntity
    }
}

public protocol EntityDetailsDataSource {
    var viewControllers: [UIViewController] { get }
    var source: EntitySource { get }
    var subsequentMatches: [EntityDetailMatch] { get }
}

open class EntityDetailsDatasourceViewModel {

    public enum State: Equatable {
        case empty
        case loading
        case result([EntityState])
        case error(Error)
    }

    public var datasource: EntityDetailsDataSource
    public weak var delegate: EntityDetailsDatasourceViewModelDelegate?

    private(set) var state: State = .empty
    private let strategy: EntityRetrieveStrategy

    public init(datasource: EntityDetailsDataSource, strategy: EntityRetrieveStrategy) {
        self.datasource = datasource
        self.strategy = strategy
    }

    public func force(_ state: State) {
        self.state = state
    }

    public func retrieve(for entity: MPOLKitEntity) {
        state = .loading
        delegate?.fancyEntityDetailsDatasourceViewModelDidBeginFetch(self)
        updateViewControllers()

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

public func == (lhs: EntityDetailsDatasourceViewModel.State, rhs: EntityDetailsDatasourceViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.result(let lhsStates), .result(let rhsStates)):
        return lhsStates == rhsStates
    default:
        return true
    }
}

