//
//  TasksListViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Delegate for task list UI events
public protocol TasksListViewControllerDelegate: class {

    /// Called when user pulls to refresh the task list
    func taskListDidPullToRefresh()

    /// Called when user changes the search text
    func taskListDidChangeSearchText(searchText: String)
}

/// View controller for displaying a list of tasks in the left hand side of the CAD split view controller
///
/// This uses CADFormCollectionViewController for consistent styling and reduced boilerplate.
///
open class TasksListViewController: CADFormCollectionViewController<TasksListItemViewModel>, UISearchBarDelegate {

    /// Delegate for UI events
    open weak var delegate: TasksListViewControllerDelegate?

    /// The refresh control for tasks list
    open private(set) var refreshControl: UIRefreshControl!

    /// The search bar for filtering tasks
    open private(set) var searchBar: UISearchBar!

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()
    }

    open func createSubviews() {
        // Add refresh control to task list
        let theme = ThemeManager.shared.theme(for: .current)
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = theme.color(forKey: .tint)
        refreshControl.addTarget(self, action: #selector(refreshTasks), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        collectionView?.alwaysBounceVertical = true

        // Add search bar for filtering task list
        searchBar = UISearchBar(frame: .zero)
        searchBar.barStyle = .black
        searchBar.showsCancelButton = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search placeholder")
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.addSubview(searchBar)

        // Disable the inset manager, as it breaks things
        collectionViewInsetManager = nil
    }

    open func createConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: collectionView!.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchBar.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Hide search bar during initial layout or rotation
        DispatchQueue.main.async {
            if self.searchBar.text?.ifNotEmpty() == nil {
                self.hideSearchBar()
            }
        }
    }

    // MARK: - Override

    override open func reloadContent() {
        let wasFocused = searchBar?.isFirstResponder ?? false

        // Refresh the task list
        collectionView?.reloadData()

        // Reloading list loses any search bar keyboard focus, so refocus if necessary
        if wasFocused {
            searchBar.becomeFirstResponder()
        }
    }
    
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
        } else if let incident = CADStateManager.shared.incidentsById[item.identifier] {
            let resource = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier).first
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        }
        
        return nil
    }

    // MARK: - CollectionViewDelegateFormLayout methods

    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        // Make space for search bar using the form global header
        return viewModel.sections.isEmpty ? 0 : 32
    }

    // MARK: - UISearchBarDelegate (cannot be in extension)

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.taskListDidChangeSearchText(searchText: searchText)
    }

    open func hideSearchBar() {
        // Clear the search text
        searchBar.text = nil
        searchBar(searchBar, textDidChange: "")

        // Hide the search bar
        if let collectionView = collectionView, collectionView.contentOffset.y < self.searchBar.bounds.height {
            collectionView.contentOffset = CGPoint(x: 0, y: self.searchBar.frame.maxY)
        }
    }

    @objc open func refreshTasks() {
        delegate?.taskListDidPullToRefresh()
    }
}
