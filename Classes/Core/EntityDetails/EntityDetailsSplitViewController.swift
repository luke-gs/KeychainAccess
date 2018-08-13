//
//  EntityDetailsSplitViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EntityDetailsSplitViewController<Details: EntityDetailDisplayable, Summary: EntitySummaryDisplayable>: SidebarSplitViewController, EntityDetailsDatasourceViewModelDelegate, EntityDetailsPickerDelegate {

    private let headerView = SidebarHeaderView(frame: .zero)
    let viewModel: EntityDetailsViewModel<Details>
    var pickerViewModel: EntityPickerViewModel

    public required init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    required public init(viewModel: EntityDetailsViewModel<Details>, pickerViewModel: EntityPickerViewModel) {
        self.viewModel = viewModel
        self.pickerViewModel = pickerViewModel
        let viewControllers = viewModel.selectedDatasourceViewModel.datasource.viewControllers
        super.init(detailViewControllers: viewControllers)

        regularSidebarViewController.title = title
        regularSidebarViewController.headerView = headerView

        viewModel.datasourceViewModels.forEach{$0.delegate = self}
        viewModel.pickerDelegate = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        updateHeader(with: viewModel.referenceEntity)
        updateSourceItems()

        viewModel.selectedDatasourceViewModel.retrieve(for: viewModel.referenceEntity)
    }

    // MARK:- Private

    private func updateSourceItems() {
        let viewModels = viewModel.datasourceViewModels

        let items: [SourceItem] = viewModels.map { viewModel in
            return SourceItem(title: viewModel.datasource.source.localizedBarTitle,
                              state: viewModel.sourceItemState())
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

    // MARK:- SidebarDelegate

    open override func sidebarViewController(_ controller: UIViewController, didSelectSourceAt index: Int) {
        let datasource = viewModel.datasourceViewModels[index].datasource
        guard !(datasource.source == viewModel.selectedDatasourceViewModel.datasource.source) else { return }
        viewModel.didSelectSourceAt(index, from: controller)
        updateViewControllers()
    }

    open override func sidebarViewController(_ controller: UIViewController, didRequestToLoadSourceAt index: Int) {
        viewModel.didRequestToLoadSourceAt(index, from: controller)
        sidebarViewController(controller, didSelectSourceAt: index)
    }

    // MARK:- EntityDetailsDatasourceViewModelDelegate

    public func entityDetailsDatasourceViewModelDidBeginFetch<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>) where U : EntityDetailDisplayable {
        updateSourceItems()
        updateViewControllers()
    }

    public func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didEndFetchWith state: EntityDetailState) where U : EntityDetailDisplayable {
        updateSourceItems()
        updateViewControllers()
        self.viewModel.fetchSubsequent()
    }

    //MARK:- EntityDetailsPickerDelegate

    public func entityDetailsDatasourceViewModel<U>(_ viewModel: EntityDetailsDatasourceViewModel<U>, didPickEntity entity: MPOLKitEntity) where U : EntityDetailDisplayable {
        dismiss(animated: true, completion: nil)
        updateSourceItems()
        updateViewControllers()
    }

    public func entityDetailsDatasourceViewModelDidCancelPickingEntity<U>(_ viewmodel: EntityDetailsDatasourceViewModel<U>) where U : EntityDetailDisplayable {
        dismiss(animated: true, completion: nil)
        updateSourceItems()
        updateViewControllers()
    }
}

