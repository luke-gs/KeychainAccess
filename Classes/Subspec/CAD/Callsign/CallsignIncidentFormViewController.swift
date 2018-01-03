//
//  CallsignIncidentFormViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Form view controller for displaying current incident of callsign
open class CallsignIncidentFormViewController: FormBuilderViewController {

    open let listViewModel: TasksListIncidentViewModel?

    open let taskViewModel: IncidentTaskItemViewModel?

    // MARK: - Initializers

    public init(listViewModel: TasksListIncidentViewModel?, taskViewModel: IncidentTaskItemViewModel?) {
        self.listViewModel = listViewModel
        self.taskViewModel = taskViewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        // Show current incident with header if set
        if let listViewModel = self.listViewModel {
            builder += HeaderFormItem(text: NSLocalizedString("Current Incident", comment: "").uppercased(), style: .plain)
            builder += CustomFormItem(cellType: TasksListIncidentCollectionViewCell.self, reuseIdentifier: "cell")
                .onConfigured({ [unowned self] (cell) in
                    // Configure the cell
                    if let cell = cell as? TasksListIncidentCollectionViewCell {
                        self.decorate(cell: cell, with: listViewModel)
                    }
                })
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(64))
                .onThemeChanged({ (cell, theme) in
                    guard let cell = cell as? TasksListIncidentCollectionViewCell else { return }
                    cell.summaryView.titleLabel.textColor = theme.color(forKey: .primaryText)
                    cell.summaryView.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
                    cell.summaryView.captionLabel.textColor = theme.color(forKey: .secondaryText)
                })
                .onSelection({ [unowned self] cell in
                    // Present the incident split view controller
                    if let taskViewModel = self.taskViewModel {
                        let vc = TasksItemSidebarViewController.init(viewModel: taskViewModel)
                        self.present(vc, animated: true, completion: nil)
                    }
                })
        }
    }

    // MARK: - Theme

    open func decorate(cell: TasksListIncidentCollectionViewCell, with viewModel: TasksListIncidentViewModel) {
        cell.highlightStyle = .animated(style: .fade)
        cell.separatorStyle = .fullWidth

        cell.decorate(with: viewModel)
    }
}

