//
//  FancyEntityDetailSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class FancyEntityDetailsSplitViewController<Details: EntityDetailDisplayable, Summary: EntitySummaryDisplayable>: SidebarSplitViewController, FancyEntityDetailsDatasourceViewModelDelegate {

    private let headerView = SidebarHeaderView(frame: .zero)
    private let viewModel: FancyEntityDetailsViewModel

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    required public init(viewModel: FancyEntityDetailsViewModel) {
        self.viewModel = viewModel
        let viewControllers = viewModel.selectedDatasourceViewModel.datasource.viewControllers
        super.init(detailViewControllers: viewControllers)

        regularSidebarViewController.title = title
        regularSidebarViewController.headerView = headerView

        viewModel.datasourceViewModels.forEach{$0.delegate = self}
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
        viewModel.selectedSource = datasource.source
        updateViewControllers()
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

        viewModel.selectedSource = newViewModel.datasource.source
        sidebarViewController(controller, didSelectSourceAt: index)
    }
}
