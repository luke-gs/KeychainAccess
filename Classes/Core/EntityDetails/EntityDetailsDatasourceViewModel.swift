//
//  EntityDatasourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol EntityDetailSectionUpdatable: class {
    var genericEntity: MPOLKitEntity? { get set }
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
    func entityDetailsDatasourceViewModelDidBeginFetch<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>)
    func entityDetailsDatasourceViewModel<U>(_ viewmodel: EntityDetailsDatasourceViewModel<U>, didEndFetchWith state: EntityDetailState)
}

public protocol EntityRetrieveStrategy {
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityResultState]>?
}

public protocol EntityDetailsDataSource: class {
    var viewControllers: [UIViewController] { get }
    var source: EntitySource { get }
    var subsequentMatches: [EntityDetailMatch] { get }
}

public protocol EntityDetailsPickerDelegate: class {
    func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didPickEntity entity: MPOLKitEntity)
    func entityDetailsDatasourceViewModelDidCancelPickingEntity<U>(_ viewmodel: EntityDetailsDatasourceViewModel<U>)
}

open class EntityDetailsDatasourceViewModel<Details: EntityDetailDisplayable>: EntityPickerDelegate {

    public let datasource: EntityDetailsDataSource
    public let pickerViewModel: EntityPickerViewModel?
    private let strategy: EntityRetrieveStrategy
    var state: EntityDetailState = .empty

    public weak var delegate: EntityDetailsDatasourceViewModelDelegate?
    public weak var pickerDelegate: EntityDetailsPickerDelegate?

    public init(datasource: EntityDetailsDataSource,
                strategy: EntityRetrieveStrategy,
                entityPickerViewModel: EntityPickerViewModel? = nil)
    {
        self.pickerViewModel = entityPickerViewModel
        self.datasource = datasource
        self.strategy = strategy
    }

    public func force(_ state: EntityDetailState) {
        self.state = state
    }

    public func retrieve(for entity: MPOLKitEntity) {
        state = .loading
        delegate?.entityDetailsDatasourceViewModelDidBeginFetch(self)
        updateViewControllers()

        strategy.retrieveUsingReferenceEntity(entity)?
            .done { [weak self] states in
                guard let `self` = self else { return }
                self.state = .result(states)
                self.updateViewControllers()
                self.delegate?.entityDetailsDatasourceViewModel(self, didEndFetchWith: .result(states))
            }.catch { [weak self] error in
                guard let `self` = self else { return }
                self.state = .error(error)
                self.updateViewControllers()
                self.delegate?.entityDetailsDatasourceViewModel(self, didEndFetchWith: .error(error))
        }
    }

    public func presentEntitySelection(from context: UIViewController) {
        guard let pickerViewModel = pickerViewModel else { return }

        if case .result(let results) = state, results.count > 1 {
            let entities = results.compactMap { state -> MPOLKitEntity in
                switch state {
                case .detail(let entity):
                    return entity
                case .summary(let entity):
                    return entity
                }
            }

            pickerViewModel.entities = entities
            pickerViewModel.headerTitle = String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entities.count)

            let entityPickerVC = EntityPickerViewController(viewModel: pickerViewModel)
            entityPickerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dimissPicker))
            pickerViewModel.delegate = self

            context.presentFormSheet(entityPickerVC, animated: true)
        }
    }

    public func sourceItemState() -> SourceItem.State {
        switch state {
        case .empty:
            return .notLoaded

        case .loading:
            return .loading

        case .result(let states):
            if states.count == 0 {
                return .notAvailable
            } else if states.count == 1 {
                let entityState = states.first!
                switch entityState {
                case .summary:
                    return .notLoaded
                case .detail(let entity):
                    let displayable = Details(entity)
                    return .loaded(count: displayable.alertBadgeCount,
                                   color: displayable.alertBadgeColor ?? .lightGray)
                }
            } else {
                return .multipleResults
            }
        case .error:
            return .notAvailable
        }
    }

    //MARK:- Private

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

    //MARK: EntityPickerDelegate

    public func finishedPicking(_ entity: MPOLKitEntity) {
        pickerDelegate?.entityDetailsDatasourceViewModel(self, didPickEntity: entity)
    }

    @objc public func dimissPicker() {
        pickerDelegate?.entityDetailsDatasourceViewModelDidCancelPickingEntity(self)
    }
}


