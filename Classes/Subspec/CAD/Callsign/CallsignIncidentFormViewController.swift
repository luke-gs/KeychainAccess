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

    open let viewModel: TasksListItemViewModel?

    // MARK: - Initializers

    public init(viewModel: TasksListItemViewModel?) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        // Show current incident with header if set
        if let viewModel = self.viewModel {
            builder += HeaderFormItem(text: NSLocalizedString("Current Incident", comment: "").uppercased(), style: .plain)
            builder += CustomFormItem(cellType: TasksListItemCollectionViewCell.self, reuseIdentifier: "cell")
                .onConfigured({ [unowned self] (cell) in
                    if let cell = cell as? TasksListItemCollectionViewCell {
                        self.decorate(cell: cell, with: viewModel)
                    }
                })
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(64))
        }
    }

    // MARK: - Theme

    private var theme: Theme {
        return ThemeManager.shared.theme(for: .current)
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        // Apply theme to custom cell
        if let cell = cell as? TasksListItemCollectionViewCell {
            cell.titleLabel.textColor = theme.color(forKey: .primaryText)
            cell.subtitleLabel.textColor = theme.color(forKey: .secondaryText)
            cell.captionLabel.textColor = theme.color(forKey: .secondaryText)
        }
    }

    open func decorate(cell: TasksListItemCollectionViewCell, with viewModel: TasksListItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .fullWidth

        cell.titleLabel.text = viewModel.title
        cell.subtitleLabel.text = viewModel.subtitle
        cell.captionLabel.text = viewModel.caption
        cell.updatesIndicator.isHidden = true

        cell.configurePriority(text: viewModel.badgeText,
                               textColor: viewModel.badgeTextColor,
                               fillColor: viewModel.badgeFillColor,
                               borderColor: viewModel.badgeBorderColor)
    }
}

