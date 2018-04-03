//
//  ClusterTasksViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// View controller for showing
open class ClusterTasksViewController: FormBuilderViewController {

    open var viewModel: ClusterTasksViewModel

    public init(viewModel: ClusterTasksViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.navTitle()
    }

    // MARK: - Form

    open override func construct(builder: FormBuilder) {

        for (sectionIndex, section) in viewModel.sections.enumerated() {
            let sectionCollapsible = viewModel.shouldShowExpandArrow() && !section.preventCollapse.isTrue
            builder += HeaderFormItem(text: section.title?.uppercased(),
                                      style: sectionCollapsible ? .collapsible : .plain)

            for item in section.items {
                let formItem: BaseFormItem
                if item is TasksListIncidentViewModel {
                    formItem = IncidentSummaryFormItem(viewModel: item as! TasksListIncidentViewModel)
                } else if item is TasksListResourceViewModel {
                    formItem = CustomFormItem(cellType: TasksListResourceCollectionViewCell.self,
                                              reuseIdentifier: TasksListResourceCollectionViewCell.defaultReuseIdentifier)
                } else if item is TasksListBasicViewModel {
                    formItem = CustomFormItem(cellType: TasksListBasicCollectionViewCell.self,
                                              reuseIdentifier: TasksListBasicCollectionViewCell.defaultReuseIdentifier)
                } else {
                    continue
                }


                builder += formItem
                    .highlightStyle(.fade)
                    .selectionStyle(.fade)
                    .contentMode(.top)
                    .onConfigured({ [unowned self] (cell) in
                        // Configure the cell
                        self.decorate(cell: cell, with: item)
                    })
                    .accessory(ItemAccessory.disclosure)
                    .height(.fixed(64))
                    .onThemeChanged({ (cell, theme) in
                        self.apply(theme: theme, to: cell)
                    })
                    .onSelection({ [weak self] (cell) in
                        // Set item as read and reload the section
                        (item as? TasksListIncidentViewModel)?.hasUpdates = false

                        self?.collectionView?.reloadSections(IndexSet(integer: sectionIndex))

                        if let viewModel = item.createItemViewModel() {
                            self?.present(TaskItemScreen.landing(viewModel: viewModel))
                        }
                    })
            }
        }
    }

    open func apply(theme: Theme, to cell: CollectionViewFormCell) {
        if let cell = cell as? TasksListResourceCollectionViewCell {
            cell.apply(theme: theme)
        } else if let cell = cell as? TasksListBasicCollectionViewCell {
            cell.apply(theme: theme)
        }
    }

    open func decorate(cell: CollectionViewFormCell, with viewModel: TasksListItemViewModel) {
        if let cell = cell as? TasksListResourceCollectionViewCell, let viewModel = viewModel as? TasksListResourceViewModel {
            cell.decorate(with: viewModel)
        } else if let cell = cell as? TasksListBasicCollectionViewCell, let viewModel = viewModel as? TasksListBasicViewModel {
            cell.decorate(with: viewModel)
        }
    }

}
