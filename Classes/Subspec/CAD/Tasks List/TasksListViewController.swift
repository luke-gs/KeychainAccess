//
//  TasksListViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for displaying a list of tasks in the left hand side of the CAD split view controller
///
/// This uses CADFormCollectionViewController for consistent styling and reduced boilerplate.
///
open class TasksListViewController: CADFormCollectionViewController<TasksListItemViewModel> {

    // MARK: - Override

    override open func cellType() -> CollectionViewFormCell.Type {
        return TasksListItemCollectionViewCell.self
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: TasksListItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.contentMode = .top
        cell.accessoryView = FormAccessoryView(style: .disclosure)

        if let cell = cell as? TasksListItemCollectionViewCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.captionLabel.text = viewModel.caption
            cell.configurePriority(color: viewModel.boxColor, priorityText: viewModel.boxText, priorityFilled: viewModel.boxFilled)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        if let cell = cell as? TasksListItemCollectionViewCell {
            cell.titleLabel.textColor = primaryTextColor
            cell.subtitleLabel.textColor = primaryTextColor
            cell.captionLabel.textColor = secondaryTextColor
        }
    }
    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }

    override open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return TasksListItemCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection) + 26
        }
        return 0
    }
}

