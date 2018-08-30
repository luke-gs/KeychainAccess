//
//  FancyEntityDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// The view model for the entities detail
open class EntityDetailsViewModel<Details: EntityDetailDisplayable>: EntityDetailsPickerDelegate {

    // MARK: Public

    /// The reference entity that the view model was initialised with
    public let referenceEntity: MPOLKitEntity

    /// The viewModels for all the data sources
    public let dataSourceViewModels: [EntityDetailsDataSourceViewModel<Details>]

    /// The picker delegate
    public weak var pickerDelegate: EntityDetailsPickerDelegate?

    /// The currently selected data source view model
    public var selectedDataSourceViewModel: EntityDetailsDataSourceViewModel<Details> {
        return dataSourceViewModels.first(where: {$0.dataSource.source == currentSource})!
    }

    private let recentlyViewed = UserSession.current.recentlyViewed
    private var selectedSource: EntitySource
    private var currentSource: EntitySource


    /// Intialise the view model
    ///
    /// - Parameters:
    ///   - dataSourceViewModels: The dataSources
    ///   - initialSource: The initial source to select
    ///   - referenceEntity: The intial entity to use as a reference
    public init(dataSourceViewModels: [EntityDetailsDataSourceViewModel<Details>],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.dataSourceViewModels = dataSourceViewModels
        self.selectedSource = initialSource
        self.currentSource = initialSource
        self.referenceEntity = referenceEntity

        dataSourceViewModels.forEach{$0.pickerDelegate = self}
    }

    /// Fetch all subsequent data sources
    public func fetchSubsequent() {

        // Get all the sources that want to be matched automatically
        let sourcesToMatch = selectedDataSourceViewModel.dataSource.subsequentMatches
            .filter{$0.shouldMatchAutomatically == true}
            .map{$0.sourceToMatch}

        // Filter out the dataSources that have already been fetched
        // Only filters out full results ie. .detail
        let dataSourceViewModels = sourcesToMatch.flatMap { source in
            self.dataSourceViewModels.filter { viewModel in
                if case .result(let states) = viewModel.state {
                    if states.count == 1, case .summary = states.first! {
                        return true
                    } else {
                        return false
                    }
                }
                return viewModel.dataSource.source == source
            }
        }

        // Fetch for the relevant entity
        dataSourceViewModels.forEach { viewModel in
            switch viewModel.state {
            case .fetching, .result:
                break
            case .empty, .error:
                if case .result(let states) = selectedDataSourceViewModel.state, case .detail(let entity) = states.first!  {
                    viewModel.retrieve(for: entity)
                } else {
                    viewModel.retrieve(for: referenceEntity)
                }
            }
        }
    }

    /// A source was selected by the entity details VC
    ///
    /// There is business logic here that determines whether to update the recently viewed
    /// or to present multiple entities list for selection
    ///
    /// - Parameters:
    ///   - index: The data source index
    ///   - controller: The controller to present from
    public func didSelectSourceAt(_ index: Int, from controller: UIViewController) {
        let dataSource = dataSourceViewModels[index].dataSource
        selectedSource = dataSource.source

        if shouldPresentEntityPicker() {
            presentEntitySelection(from: controller)
        } else {
            updateRecentlyViewed()
            currentSource = dataSource.source
        }
    }

    /// A source was request to fetch details from
    ///
    /// - Parameters:
    ///   - index: The data source index
    ///   - controller: The controller that requested the fetch
    public func didRequestToLoadSourceAt(_ index: Int, from controller: UIViewController) {
        let newViewModel = dataSourceViewModels[index]

        if case .result(let results) = selectedDataSourceViewModel.state {
            if results.count == 1, let result = results.first {
                if case .detail(let entity) = result {
                    newViewModel.retrieve(for: entity)
                }
            }
        }

        currentSource = newViewModel.dataSource.source
    }

    //MARK:- Private

    private func updateRecentlyViewed() {
        switch selectedDataSourceViewModel.state {
        case .result(let states):
            if states.count == 1, case .detail(let entity) = states.first! {
                if recentlyViewed.contains(entity) {
                    recentlyViewed.remove(entity)
                }
                recentlyViewed.add(entity)
            }
        default:
            break
        }
    }

    private func presentEntitySelection(from context: UIViewController) {
        guard let viewModel = dataSourceViewModels.first(where: {$0.dataSource.source == selectedSource}) else { return }
        viewModel.presentEntitySelection(from: context)
    }

    private func shouldPresentEntityPicker() -> Bool {
        if let viewModel = dataSourceViewModels.first(where: {$0.dataSource.source == selectedSource}) {
            if case .result(let results) = viewModel.state {
                if results.count >= 1, case .summary = results.first! {
                    return true
                }
                return false
            }
        }
        return false
    }

    //MARK:- EntityDetailsPickerDelegate

    public func entityDetailsDataSourceViewModel<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>, didPickEntity entity: MPOLKitEntity) where U : EntityDetailDisplayable {
        currentSource = selectedSource
        selectedDataSourceViewModel.retrieve(for: entity)
        pickerDelegate?.entityDetailsDataSourceViewModel(viewModel, didPickEntity: entity)
    }

    public func entityDetailsDataSourceViewModelDidCancelPickingEntity<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>) where U : EntityDetailDisplayable {
        selectedSource = currentSource
        pickerDelegate?.entityDetailsDataSourceViewModelDidCancelPickingEntity(viewModel)
    }
}
