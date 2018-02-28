//
//  ManageCallsignIncidentFormViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Form view controller for displaying current incident of callsign
open class ManageCallsignIncidentFormViewController: FormBuilderViewController {

    open var listViewModel: TasksListIncidentViewModel?

    // MARK: - Initializers

    public init(listViewModel: TasksListIncidentViewModel?) {
        self.listViewModel = listViewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent bounce scroll for fixed item
        collectionView?.alwaysBounceVertical = false
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
                    if let viewModel = listViewModel.createItemViewModel() {
                        self.present(TaskItemScreen.landing(viewModel: viewModel))
                    }
                })
        }
    }

    // MARK: - Theme

    open func decorate(cell: TasksListIncidentCollectionViewCell, with viewModel: TasksListIncidentViewModel) {
        cell.highlightStyle = .fade
        cell.separatorStyle = .none

        cell.decorate(with: viewModel)
    }

    // Make sure item is never actually selected
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

