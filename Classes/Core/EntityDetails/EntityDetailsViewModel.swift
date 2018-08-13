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

    public var selectedDatasourceViewModel: EntityDetailsDatasourceViewModel<Details> {
        return datasourceViewModels.first(where: {$0.datasource.source == currentSource})!
    }

    public var currentSource: EntitySource
    public var selectedSource: EntitySource

    public weak var pickerDelegate: EntityDetailsPickerDelegate?

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

        // Fetch
        datasourceViewModels.forEach { viewModel in
            var entityStates: [EntityResultState] = []

            func fetch() {
                if entityStates.count == 1 {
                    let entityState = entityStates.first!
                    switch entityState {
                    case .summary(let entity):
                        viewModel.retrieve(for: entity)
                    case .detail(let entity):
                        viewModel.retrieve(for: entity)
                    }
                }
            }

            switch viewModel.state {
            case .loading:
                break
            case .result(let states):
                entityStates = states
                fetch()
            case .empty, .error:
                if case .result(let states) = selectedDatasourceViewModel.state {
                    entityStates = states
                    fetch()
                }
            }
        }
    }

    public func shouldPresentEntityPicker() -> Bool {
        if let viewModel = datasourceViewModels.first(where: {$0.datasource.source == selectedSource}) {
            if case .result(let results) = viewModel.state, results.count > 1 {
                return true
            }
        }
        return false
    }

    public func presentEntitySelection(from context: UIViewController) {
        guard let viewModel = datasourceViewModels.first(where: {$0.datasource.source == selectedSource}) else { return }
        viewModel.presentEntitySelection(from: context)
    }

    public func didSelectSourceAt(_ index: Int, from controller: UIViewController) {
        let datasource = datasourceViewModels[index].datasource
        selectedSource = datasource.source

        if shouldPresentEntityPicker() {
            presentEntitySelection(from: controller)
        } else {
            currentSource = datasource.source
        }
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
