//
//  EntityDataSourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class EntityDetailsDataSourceViewModel<Details: EntityDetailDisplayable>: EntityPickerDelegate {

    // MARK:- Public

    /// The data source
    public let dataSource: EntityDetailsDataSource

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
    public weak var delegate: EntityDetailsDataSourceViewModelDelegate?

    /// The picked delegate responsible for handling the entity picking results
    public weak var pickerDelegate: EntityDetailsPickerDelegate?

    /// Initialise the viewModel
    ///
    /// - Parameters:
    ///   - dataSource: The data source
    ///   - strategy: The retrieval strategy
    ///   - entityPickerViewModel: The pickerviewModel
    public init(dataSource: EntityDetailsDataSource,
                strategy: EntityRetrievalStrategy,
                entityPickerViewModel: EntityPickerViewModel? = nil)
    {
        self.pickerViewModel = entityPickerViewModel
        self.dataSource = dataSource
        self.strategy = strategy
    }

    /// Retrieve details using the entity
    ///
    /// - Parameter entity: The entity to use to retrieve details for
    public func retrieve(for entity: MPOLKitEntity) {
        state = .fetching
        delegate?.entityDetailsDataSourceViewModelDidBeginFetch(self)
        updateViewControllers()

        strategy.retrieveUsingReferenceEntity(entity)?
            .done { [weak self] states in
                guard let `self` = self else { return }
                self.state = .result(states)
                self.updateViewControllers()
                self.delegate?.entityDetailsDataSourceViewModel(self, didEndFetchWith: .result(states))
            }.catch { [weak self] error in
                guard let `self` = self else { return }
                self.state = .error(error)
                self.updateViewControllers()
                self.delegate?.entityDetailsDataSourceViewModel(self, didEndFetchWith: .error(error))
        }
    }

    /// Present the entity selection screen
    ///
    /// - Parameter context: The context to present from
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
        let viewControllersToUpdate: [EntityDetailSectionUpdatable] = dataSource.viewControllers.compactMap{$0 as? EntityDetailSectionUpdatable}

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

    @objc private func dimissPicker() {
        pickerDelegate?.entityDetailsDataSourceViewModelDidCancelPickingEntity(self)
    }

    //MARK:- EntityPickerDelegate

    public func finishedPicking(_ entity: MPOLKitEntity) {
        pickerDelegate?.entityDetailsDataSourceViewModel(self, didPickEntity: entity)
    }
}

/// Get notified when the Entity Details Section has updated with new data
public protocol EntityDetailSectionUpdatable: class {

    /// The entity that will be updated
    var entity: MPOLKitEntity? { get set }

    /// The loading manager state that will be updated
    var loadingManager: LoadingStateManager { get }
}

/// Gets called when the something happens on the entity details entity picker `EntityDetailsDataSourceViewModel`
public protocol EntityDetailsPickerDelegate: class {

    /// Called when the user has picked an entity from the entity list
    ///
    /// - Parameters:
    ///   - viewModel: the viewModel that the entity was picked for
    ///   - entity: the entity
    func entityDetailsDataSourceViewModel<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>, didPickEntity entity: MPOLKitEntity)

    /// Called when the user cancelled out of picking an entity
    ///
    /// - Parameter viewModel: The viewModel that he entity wasn't picked for
    func entityDetailsDataSourceViewModelDidCancelPickingEntity<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>)
}

/// Gets called when the `EntityDetailsDataSourceViewModel` began and ended fetching in entity details
public protocol EntityDetailsDataSourceViewModelDelegate: class {

    /// Called when the viewModel did begin fetching entity details
    ///
    /// - Parameter viewModel: The viewModel that began fetching details
    func entityDetailsDataSourceViewModelDidBeginFetch<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>)

    /// Called when the viewModel finished fetching entity details
    ///
    /// - Parameters:
    ///   - viewModel: The viewModel that finished fetching
    ///   - state: The entity detail state of the result
    func entityDetailsDataSourceViewModel<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>, didEndFetchWith state: EntityDetailState)
}

/// The dataSource used for the entity details section
public protocol EntityDetailsDataSource: class {

    /// The viewControllers to display as sections
    var viewControllers: [UIViewController] { get }

    /// The source of the dataSource
    var source: EntitySource { get }

    /// The subsequent matches to fetch when that dataSource is loaded
    var subsequentMatches: [EntityDetailMatch] { get }
}

