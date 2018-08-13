//
//  EntityDatasourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class EntityDetailsDatasourceViewModel<Details: EntityDetailDisplayable>: EntityPickerDelegate {

    // MARK:- Public

    /// The data source
    public let datasource: EntityDetailsDataSource

    /// The entity picker view model
    ///
    /// Used in the case where entities need to be picked from a list
    /// if the results from a fetch are multiple
    public let pickerViewModel: EntityPickerViewModel?

    /// The strategy for the entity retrieval
    public let strategy: EntityRetrievalStrategy

    /// The current state of the entity details fetch
    public var state: EntityDetailState = .empty

    /// The viewModel delegate responsible for handling the fetch results
    public weak var delegate: EntityDetailsDatasourceViewModelDelegate?

    /// The picked delegate responsible for handling the entity picking results
    public weak var pickerDelegate: EntityDetailsPickerDelegate?

    /// Initialise the viewmodel
    ///
    /// - Parameters:
    ///   - datasource: the datasource
    ///   - strategy: the retrieval strategy
    ///   - entityPickerViewModel: the pickerviewmodel
    public init(datasource: EntityDetailsDataSource,
                strategy: EntityRetrievalStrategy,
                entityPickerViewModel: EntityPickerViewModel? = nil)
    {
        self.pickerViewModel = entityPickerViewModel
        self.datasource = datasource
        self.strategy = strategy
    }

    /// Retrieve details using the entity
    ///
    /// - Parameter entity: the entity to use to retrieve details for
    public func retrieve(for entity: MPOLKitEntity) {
        state = .fetching
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

    /// Present the entity selection screen
    ///
    /// - Parameter context: the context to present from
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

    /// The source item's state for the current result state
    ///
    /// - Returns: the source item state
    public func sourceItemState() -> SourceItem.State {
        switch state {
        case .empty:
            return .notLoaded

        case .fetching:
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
        case .fetching:
            viewControllersToUpdate.forEach{$0.loadingManager.state = .loading}
        case .result(let states):
            if states.count == 1 {
                let entityState = states.first!
                switch entityState {
                case .summary(let entity), .detail(let entity):
                    viewControllersToUpdate.forEach{$0.entity = entity}
                    viewControllersToUpdate.forEach{$0.loadingManager.state = .loaded}
                }
            } else {
                viewControllersToUpdate.forEach{$0.loadingManager.state = .noContent}
            }
        case .error:
            viewControllersToUpdate.forEach{$0.loadingManager.state = .error}
        }
    }

    //MARK:- EntityPickerDelegate

    public func finishedPicking(_ entity: MPOLKitEntity) {
        pickerDelegate?.entityDetailsDatasourceViewModel(self, didPickEntity: entity)
    }

    @objc public func dimissPicker() {
        pickerDelegate?.entityDetailsDatasourceViewModelDidCancelPickingEntity(self)
    }
}

/// Get notified when the Entity Details Section has updated with new data
public protocol EntityDetailSectionUpdatable: class {

    /// The entity that will be updated
    var entity: MPOLKitEntity? { get set }

    /// The loading manager state that will be updated
    var loadingManager: LoadingStateManager { get }
}

/// Gets called when the something happens on the entity details entity picker `EntityDetailsDatasourceViewModel`
public protocol EntityDetailsPickerDelegate: class {

    /// Called when the user has picked an entity from the entity list
    ///
    /// - Parameters:
    ///   - viewModel: the viewmodel that the entity was picked for
    ///   - entity: the entity
    func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didPickEntity entity: MPOLKitEntity)

    /// Called when the user cancelled out of picking an entity
    ///
    /// - Parameter viewmodel: the viewmodel that he entity wasn't picked for
    func entityDetailsDatasourceViewModelDidCancelPickingEntity<U>(_ viewmodel: EntityDetailsDatasourceViewModel<U>)
}

/// Gets called when the `EntityDetailsDatasourceViewModel` began and ended fetching in entity details
public protocol EntityDetailsDatasourceViewModelDelegate: class {

    /// Called when the viewmodel did begin fetching entity details
    ///
    /// - Parameter viewModel: the viewmodel that began fetching details
    func entityDetailsDatasourceViewModelDidBeginFetch<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>)

    /// Called when the viewmodel finished fetching entity details
    ///
    /// - Parameters:
    ///   - viewModel: the viewmodel that finished fetching
    ///   - state: the entity detail state of the result
    func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didEndFetchWith state: EntityDetailState)
}

/// The datasource used for the entity details section
public protocol EntityDetailsDataSource: class {

    /// The viewControllers to display as sections
    var viewControllers: [UIViewController] { get }

    /// The source of the datasource
    var source: EntitySource { get }

    /// The subsequent matches to fetch when that datasource is loaded
    var subsequentMatches: [EntityDetailMatch] { get }
}

