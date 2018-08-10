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

    private func updateSourceItems() {
        let states = viewModel.datasourceViewModels

        let items: [SourceItem] = states.map { viewModel in
            var itemState: SourceItem.State = .notLoaded
            let state = viewModel.state

            switch state {
            case .empty:
                itemState = .notLoaded

            case .loading:
                itemState = .loading

            case .result(let states):
                if states.count == 1 {
                    let entityState = states.first!
                    switch entityState {
                    case .summary(let entity):
                        //TODO: Something?
                        break
                    case .detail(let entity):
                        let displayable = Details(entity)
                        itemState = .loaded(count: displayable.alertBadgeCount, color: displayable.alertBadgeColor ?? .lightGray)
                    }
                } else {
                    itemState = .multipleResults
                }

            case .error:
                itemState = .notLoaded
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

    // MARK:- FancyEntityDetailsDatasourceViewModelDelegate

    public func fancyEntityDetailsDatasourceViewModelDidBeginFetch(_ viewModel: FancyEntityDetailsDatasourceViewModel) {
       updateSourceItems()
    }

    public func fancyEntityDetailsDatasourceViewModel(_ viewmodel: FancyEntityDetailsDatasourceViewModel, didEndFetchWith state: FancyEntityDetailsDatasourceViewModel.State) {
        updateSourceItems()
    }
}
