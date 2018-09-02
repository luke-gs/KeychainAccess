//
//  EntityDetailsSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// The entity details split view controller
public class EntityDetailsSplitViewController<Details: EntityDetailDisplayable, Summary: EntitySummaryDisplayable>: SidebarSplitViewController, EntityDetailsDataSourceViewModelDelegate, EntityDetailsPickerDelegate {

    // MARK:- Public

    /// The viewModel for the entity details view controller
    public let viewModel: EntityDetailsViewModel<Details>

    private let headerView = SidebarHeaderView(frame: .zero)

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    required public init(viewModel: EntityDetailsViewModel<Details>) {
        self.viewModel = viewModel
        let viewControllers = viewModel.selectedDataSourceViewModel.dataSource.viewControllers
        super.init(detailViewControllers: viewControllers)

        regularSidebarViewController.title = title
        regularSidebarViewController.headerView = headerView

        viewModel.dataSourceViewModels.forEach{$0.delegate = self}
        viewModel.pickerDelegate = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        updateHeader(with: viewModel.referenceEntity)
        updateSourceItems()

        viewModel.selectedDataSourceViewModel.retrieve(for: viewModel.referenceEntity)
    }

    // MARK:- Private

    private func updateSourceItems() {
        let viewModels = viewModel.dataSourceViewModels

        let items: [SourceItem] = viewModels.map { viewModel in
            return SourceItem(title: viewModel.dataSource.source.localizedBarTitle,
                              state: viewModel.sourceItemState())
        }

        let index = viewModel.dataSourceViewModels.index(where: {$0.dataSource.source == viewModel.selectedDataSourceViewModel.dataSource.source})
    
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
        detailViewControllers = viewModel.selectedDataSourceViewModel.dataSource.viewControllers
        selectedViewController = detailViewControllers.first
    }

    // MARK:- SidebarDelegate

    open override func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
        let dataSource = viewModel.dataSourceViewModels[index].dataSource
        guard !(dataSource.source == viewModel.selectedDataSourceViewModel.dataSource.source) else { return }
        viewModel.didSelectSourceAt(index, from: controller)
        updateViewControllers()
    }

    open override func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
        viewModel.didRequestToLoadSourceAt(index, from: controller)
        sidebarViewController(controller, didSelectSourceAt: index)
    }

    // MARK:- EntityDetailsDataSourceViewModelDelegate

    public func entityDetailsDataSourceViewModelDidBeginFetch<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>) where U : EntityDetailDisplayable {
        updateSourceItems()
        updateViewControllers()
    }

    public func entityDetailsDataSourceViewModel<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>, didEndFetchWith state: EntityDetailState) where U : EntityDetailDisplayable {
        
        if let index = self.viewModel.dataSourceViewModels.index(where: {$0.dataSource.source == viewModel.dataSource.source}) {
            self.viewModel.didFinishLoadingSourceAt(index)
        }

        updateSourceItems()
        updateViewControllers()
        self.viewModel.fetchSubsequent()
    }

    //MARK:- EntityDetailsPickerDelegate

    public func entityDetailsDataSourceViewModel<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>, didPickEntity entity: MPOLKitEntity) where U : EntityDetailDisplayable {
        dismiss(animated: true, completion: nil)
        updateSourceItems()
        updateViewControllers()
    }

    public func entityDetailsDataSourceViewModelDidCancelPickingEntity<U>(_ viewModel: EntityDetailsDataSourceViewModel<U>) where U : EntityDetailDisplayable {
        dismiss(animated: true, completion: nil)
        updateSourceItems()
        updateViewControllers()
    }
}

