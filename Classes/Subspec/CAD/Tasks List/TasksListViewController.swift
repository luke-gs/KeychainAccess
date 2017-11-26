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
            cell.updatesIndicator.isHidden = !viewModel.hasUpdates
            cell.configurePriority(color: viewModel.boxColor, priorityText: viewModel.boxText, priorityFilled: viewModel.boxFilled)
            
            cell.detailLabel.text = viewModel.description
            cell.setStatusRows(viewModel.resources)
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
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        
        if let header = view as? CollectionViewFormHeaderView, let viewModel = viewModel as? TasksListViewModel {
            header.showsUpdatesIndicatorWhenCollapsed = viewModel.showsUpdatesIndicator(at: indexPath.section)
        }
        
        return view
    }
    
    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
        
        // Set item as read and reload the section
        let item = viewModel.item(at: indexPath)
        item?.hasUpdates = false
        
        collectionView.reloadSections(IndexSet(integer: indexPath.section))
    }

    override open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let _ = viewModel.item(at: indexPath) {
            return 64
        }
        return 0
    }
}

