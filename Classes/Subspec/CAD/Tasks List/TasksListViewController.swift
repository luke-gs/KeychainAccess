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

    /// The global header height for offsetting content in list
    open var globalHeaderHeight: CGFloat = 0

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
            cell.configurePriority(text: viewModel.badgeText,
                                   textColor: viewModel.badgeTextColor,
                                   fillColor: viewModel.badgeFillColor,
                                   borderColor: viewModel.badgeBorderColor)
            
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
        
        // Set item as read and reload the section
        guard let item = viewModel.item(at: indexPath) else { return }
        item.hasUpdates = false
        
        collectionView.reloadSections(IndexSet(integer: indexPath.section))
        
        if let viewModel = viewModel(for: item) {
            let vc = TasksItemSidebarViewController.init(viewModel: viewModel)
            splitViewController?.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    override open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let _ = viewModel.item(at: indexPath) {
            return 64
        }
        return 0
    }
    
    /// Creates a view model from an annotation
    public func viewModel(for item: TasksListItemViewModel) -> TaskItemViewModel? {
        if let resource = CADStateManager.shared.resourcesById[item.identifier] {
            return ResourceTaskItemViewModel(resource: resource)
        } else if let incident = CADStateManager.shared.incidentsById[item.identifier],
            let resource = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier).first
        {
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        }
        
        return nil
    }

    // MARK: - CollectionViewDelegateFormLayout methods

    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return viewModel.sections.isEmpty ? 0 : globalHeaderHeight
    }
}
