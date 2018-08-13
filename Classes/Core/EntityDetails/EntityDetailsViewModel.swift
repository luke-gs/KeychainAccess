//
//  FancyEntityDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EntityDetailsViewModel<Details: EntityDetailDisplayable>: EntityDetailsPickerDelegate {

    public let referenceEntity: MPOLKitEntity
    public let datasourceViewModels: [EntityDetailsDatasourceViewModel<Details>]

    public weak var pickerDelegate: EntityDetailsPickerDelegate?
    public var selectedDatasourceViewModel: EntityDetailsDatasourceViewModel<Details> {
        return datasourceViewModels.first(where: {$0.datasource.source == currentSource})!
    }

    private var selectedSource: EntitySource
    private var currentSource: EntitySource
    
    public init(datasourceViewModels: [EntityDetailsDatasourceViewModel<Details>],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.datasourceViewModels = datasourceViewModels
        self.selectedSource = initialSource
        self.currentSource = initialSource
        self.referenceEntity = referenceEntity

        datasourceViewModels.forEach{$0.pickerDelegate = self}
    }

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
            case .loading:
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

    public func updateRecentlyViewed() {
        switch selectedDatasourceViewModel.state {
        case .result(let states):
            if states.count == 1, case .detail(let entity) = states.first! {
                UserSession.current.recentlyViewed.add(entity)
            }
        default:
            break
        }
    }

    //MARK:- Private

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
