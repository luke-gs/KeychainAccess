//
//  FancyEntityDetailSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class FancyEntityDetailsSplitViewController<Details: EntityDetailDisplayable, Summary: EntitySummaryDisplayable>: SidebarSplitViewController, FancyEntityDetailsDatasourceViewModelDelegate, EntityPickerDelegate {

    private let headerView = SidebarHeaderView(frame: .zero)
    let viewModel: FancyEntityDetailsViewModel
    var pickerViewModel: EntityPickerViewModel

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    required public init(viewModel: FancyEntityDetailsViewModel, pickerViewModel: EntityPickerViewModel) {
        self.viewModel = viewModel
        self.pickerViewModel = pickerViewModel
        let viewControllers = viewModel.selectedDatasourceViewModel.datasource.viewControllers
        super.init(detailViewControllers: viewControllers)

        regularSidebarViewController.title = title
        regularSidebarViewController.headerView = headerView

        viewModel.datasourceViewModels.forEach{$0.delegate = self}
        self.pickerViewModel.delegate = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        updateHeader(with: viewModel.referenceEntity)
        updateSourceItems()

        viewModel.selectedDatasourceViewModel.retrieve(for: viewModel.referenceEntity)
    }

    // MARK:- Private

    private func fetchSubsequent() {

        // Get all the sources that want to be matched automatically
        let sourcesToMatch = viewModel.selectedDatasourceViewModel.datasource.subsequentMatches
            .filter{$0.shouldMatchAutomatically == true}
            .map{$0.sourceToMatch}

        // Filter out the datasources that have already been fetched
        let datasourceViewModels = sourcesToMatch.flatMap { source in
            viewModel.datasourceViewModels.filter { viewModel in
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
            var entityStates: [EntityState] = []

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
                if case .result(let states) = self.viewModel.selectedDatasourceViewModel.state {
                    entityStates = states
                    fetch()
                }
            }
        }
    }

    private func updateSourceItems() {
        let viewModels = viewModel.datasourceViewModels

        let items: [SourceItem] = viewModels.map { viewModel in
            var itemState: SourceItem.State = .notLoaded
            let state = viewModel.state

            switch state {
            case .empty:
                itemState = .notLoaded

            case .loading:
                itemState = .loading

            case .result(let states):
                if states.count == 0 {
                    itemState = .notAvailable
                } else if states.count == 1 {
                    let entityState = states.first!
                    switch entityState {
                    case .summary:
                        itemState = .notLoaded
                    case .detail(let entity):
                        let displayable = Details(entity)
                        itemState = .loaded(count: displayable.alertBadgeCount,
                                            color: displayable.alertBadgeColor ?? .lightGray)
                    }
                } else {
                    itemState = .multipleResults
                }
            case .error:
                itemState = .notAvailable
            }

            return SourceItem(title: viewModel.datasource.source.localizedBarTitle, state: itemState)
        }

        let index = viewModel.datasourceViewModels.index(where: {$0.datasource.source == viewModel.selectedDatasourceViewModel.datasource.source})

        regularSidebarViewController.sourceItems =  items
        regularSidebarViewController.selectedSourceIndex = index

        // Apply same source items to compact sidebar
        compactSidebarViewController.sourceItems = regularSidebarViewController.sourceItems
        compactSidebarViewController.selectedSourceIndex = regularSidebarViewController.selectedSourceIndex
    }

    private func updateHeader(with entity: MPOLKitEntity) {
        let detailDisplayable = Details(entity)
        let summaryDisplayable = Summary(entity)

        headerView.captionLabel.text = detailDisplayable.entityDisplayName?.localizedUppercase
        headerView.titleLabel.text = summaryDisplayable.title

        if let thumbnailInfo = summaryDisplayable.thumbnail(ofSize: .small) {
            headerView.iconView.setImage(with: thumbnailInfo)
        }

        if let lastUpdated = detailDisplayable.lastUpdatedString {
            headerView.subtitleLabel.text = NSLocalizedString("Updated ", comment: "") + lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }

        regularSidebarViewController.sidebarTableView?.reloadData()
    }

    private func updateViewControllers() {
        detailViewControllers = viewModel.selectedDatasourceViewModel.datasource.viewControllers
        selectedViewController = detailViewControllers.first
    }

    private func presentEntitySelection(with results: [EntityState]) {
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
        entityPickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dimissPicker))

        presentFormSheet(entityPickerVC, animated: true)
    }

    @objc private func dimissPicker() {
        dismiss(animated: true, completion: nil)
        viewModel.selectedSource = viewModel.currentSource
        updateSourceItems()
        updateViewControllers()
    }

    // MARK:- FancyEntityDetailsDatasourceViewModelDelegate

    public func fancyEntityDetailsDatasourceViewModelDidBeginFetch(_ viewModel: FancyEntityDetailsDatasourceViewModel) {
        updateSourceItems()
        updateViewControllers()
    }

    public func fancyEntityDetailsDatasourceViewModel(_ viewmodel: FancyEntityDetailsDatasourceViewModel, didEndFetchWith state: FancyEntityDetailsDatasourceViewModel.State) {
        updateSourceItems()
        updateViewControllers()
        fetchSubsequent()
    }

    // MARK: - SideBar Delegate

    open override func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
        let datasource = viewModel.datasourceViewModels[index].datasource
        guard !(datasource.source == viewModel.selectedDatasourceViewModel.datasource.source) else { return }

        if case .result(let results) = viewModel.datasourceViewModels[index].state, results.count > 1 {
            viewModel.selectedSource = datasource.source
            presentEntitySelection(with: results)
        } else {
            viewModel.currentSource = datasource.source
            updateViewControllers()
        }
    }

    open override func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
        let newViewModel = viewModel.datasourceViewModels[index]

        if case .result(let results) = viewModel.selectedDatasourceViewModel.state {
            if results.count == 1, let result = results.first {
                if case .detail(let entity) = result {
                    newViewModel.retrieve(for: entity)
                }
            }
        }

        viewModel.currentSource = newViewModel.datasource.source
        sidebarViewController(controller, didSelectSourceAt: index)
    }

    // MARK: EntityPickerDelegate
    public func finishedPicking(_ entity: MPOLKitEntity) {
        viewModel.currentSource = viewModel.selectedSource
        viewModel.selectedDatasourceViewModel.retrieve(for: entity)
        dismissAnimated()
    }
}
