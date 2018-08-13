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
    public let datasourceViewModels: [EntityDetailsDatasourceViewModel<Details>]

    /// The picker delegate
    public weak var pickerDelegate: EntityDetailsPickerDelegate?

    /// The currently selected data source view model
    public var selectedDatasourceViewModel: EntityDetailsDatasourceViewModel<Details> {
        return datasourceViewModels.first(where: {$0.datasource.source == currentSource})!
    }

    private let recentlyViewed = UserSession.current.recentlyViewed
    private var selectedSource: EntitySource
    private var currentSource: EntitySource


    /// Intialise the view model
    ///
    /// - Parameters:
    ///   - datasourceViewModels: the datasources
    ///   - initialSource: the initial source to select
    ///   - referenceEntity: the intial entity to use as a reference
    public init(datasourceViewModels: [EntityDetailsDatasourceViewModel<Details>],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.datasourceViewModels = datasourceViewModels
        self.selectedSource = initialSource
        self.currentSource = initialSource
        self.referenceEntity = referenceEntity

        datasourceViewModels.forEach{$0.pickerDelegate = self}
    }

    /// Fetch all subsequent data sources
    public func fetchSubsequent() {

        // Get all the sources that want to be matched automatically
        let sourcesToMatch = selectedDatasourceViewModel.datasource.subsequentMatches
            .filter{$0.shouldMatchAutomatically == true}
            .map{$0.sourceToMatch}

        // Filter out the datasources that have already been fetched
        // Only filters out full results ie. .detail
        let datasourceViewModels = sourcesToMatch.flatMap { source in
            self.datasourceViewModels.filter { viewModel in
                if case .result(let states) = viewModel.state {
                    if states.count == 1, case .summary = states.first! {
                        return true
                    } else {
                        return false
                    }
                }
                return viewModel.datasource.source == source
            }
        }

        // Fetch for the relevant entity
        datasourceViewModels.forEach { viewModel in
            switch viewModel.state {
            case .fetching:
                break
            case .result(let states):
                if states.count == 1, case .summary(let entity) = states.first! {
                    viewModel.retrieve(for: entity)
                }
            case .empty, .error:
                if case .result(let states) = selectedDatasourceViewModel.state, case .detail(let entity) = states.first!  {
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
    ///   - index: the data source index
    ///   - controller: the controller to present from
    public func didSelectSourceAt(_ index: Int, from controller: UIViewController) {
        let datasource = datasourceViewModels[index].datasource
        selectedSource = datasource.source

        if shouldPresentEntityPicker() {
            presentEntitySelection(from: controller)
        } else {
            updateRecentlyViewed()
            currentSource = datasource.source
        }
    }

    /// A source was request to fetch details from
    ///
    /// - Parameters:
    ///   - index: the data source index
    ///   - controller: the controller that requested the fetch
    public func didRequestToLoadSourceAt(_ index: Int, from controller: UIViewController) {
        let newViewModel = datasourceViewModels[index]

        if case .result(let results) = selectedDatasourceViewModel.state {
            if results.count == 1, let result = results.first {
                if case .detail(let entity) = result {
                    newViewModel.retrieve(for: entity)
                }
            }
        }

        currentSource = newViewModel.datasource.source
    }

    //MARK:- Private

    private func updateRecentlyViewed() {
        switch selectedDatasourceViewModel.state {
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
        guard let viewModel = datasourceViewModels.first(where: {$0.datasource.source == selectedSource}) else { return }
        viewModel.presentEntitySelection(from: context)
    }

    private func shouldPresentEntityPicker() -> Bool {
        if let viewModel = datasourceViewModels.first(where: {$0.datasource.source == selectedSource}) {
            if case .result(let results) = viewModel.state, results.count > 1 {
                return true
            }
        }
        return false
    }

    //MARK:- EntityDetailsPickerDelegate

    public func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didPickEntity entity: MPOLKitEntity) where U : EntityDetailDisplayable {
        currentSource = selectedSource
        selectedDatasourceViewModel.retrieve(for: entity)
        pickerDelegate?.entityDetailsDatasourceViewModel(viewModel, didPickEntity: entity)
    }

    public func entityDetailsDatasourceViewModelDidCancelPickingEntity<U>(_ viewmodel: EntityDetailsDatasourceViewModel<U>) where U : EntityDetailDisplayable {
        selectedSource = currentSource
        pickerDelegate?.entityDetailsDatasourceViewModelDidCancelPickingEntity(viewmodel)
    }
}
