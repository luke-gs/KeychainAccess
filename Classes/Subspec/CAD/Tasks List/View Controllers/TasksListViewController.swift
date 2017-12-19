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
open class TasksListViewController: FormBuilderViewController, UISearchBarDelegate {

    open var viewModel: TasksListViewModel
    
    /// Delegate for UI events
    open weak var delegate: TasksListViewControllerDelegate?

    /// The refresh control for tasks list
    open private(set) var refreshControl: UIRefreshControl!

    /// The search bar for filtering tasks
    open private(set) var searchBar: UISearchBar!

    public init(viewModel: TasksListViewModel) {
        self.viewModel = viewModel
        super.init()
        self.viewModel.delegate = self
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()
        
        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
        
        sectionsUpdated()
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

    open override func construct(builder: FormBuilder) {
        for (_, section) in viewModel.sections.enumerated() {
            builder += HeaderFormItem(text: section.title.uppercased(),
                                      style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)
            
            for item in section.items {
                let formItem: BaseFormItem
                if item is TasksListIncidentViewModel {
                    formItem = CustomFormItem(cellType: TasksListIncidentCollectionViewCell.self,
                                              reuseIdentifier: TasksListIncidentCollectionViewCell.defaultReuseIdentifier)
                } else if item is TasksListResourceViewModel {
                    formItem = CustomFormItem(cellType: TasksListResourceCollectionViewCell.self,
                                              reuseIdentifier: TasksListResourceCollectionViewCell.defaultReuseIdentifier)
                } else {
                    continue
                }
                
                
                builder += formItem
                    .onConfigured({ [unowned self] (cell) in
                        // Configure the cell
                        self.decorate(cell: cell, with: item)
                    })
                    .accessory(ItemAccessory.disclosure)
                    .height(.fixed(64))
                    .onThemeChanged({ (cell, theme) in
                        self.apply(theme: theme, to: cell)
                    })
            }
        }
    }
    
    open func apply(theme: Theme, to cell: CollectionViewFormCell) {
        if let cell = cell as? TasksListIncidentCollectionViewCell {
            cell.apply(theme: theme)
        } else if let cell = cell as? TasksListResourceCollectionViewCell {
            cell.apply(theme: theme)
        }
    }
    
    open func decorate(cell: CollectionViewFormCell, with viewModel: TasksListItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.contentMode = .top
        
        
        if let cell = cell as? TasksListIncidentCollectionViewCell, let viewModel = viewModel as? TasksListIncidentViewModel {
            cell.decorate(with: viewModel)
        } else if let cell = cell as? TasksListResourceCollectionViewCell, let viewModel = viewModel as? TasksListResourceViewModel {
            cell.decorate(with: viewModel)
        }
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

    open func reloadContent() {
        let wasFocused = searchBar?.isFirstResponder ?? false

        // Refresh the task list
        reloadForm()

        // Reloading list loses any search bar keyboard focus, so refocus if necessary
        if wasFocused {
            searchBar.becomeFirstResponder()
        }
    }

    // MARK: - UICollectionViewDelegate

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        // Set item as read and reload the section
        guard let item = viewModel.item(at: indexPath) else { return }
        (item as? TasksListIncidentViewModel)?.hasUpdates = false

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

    public func viewModel(for item: TasksListItemViewModel) -> TaskItemViewModel? {
        if let resource = CADStateManager.shared.resourcesById[item.identifier] {
            return ResourceTaskItemViewModel(resource: resource)
        } else if let incident = CADStateManager.shared.incidentsById[item.identifier] {
            // Show details of our resource if we are assigned to incident
            let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier)
            var resource: SyncDetailsResource? = nil
            if let currentResource = CADStateManager.shared.currentResource {
                resource = resources.contains(currentResource) ? currentResource : nil
            }
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

extension TasksListViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        // Update loading state
        loadingManager.state = viewModel.numberOfSections() == 0 ? .noContent : .loaded
        
        // Reload content
        reloadContent()
    }
}
