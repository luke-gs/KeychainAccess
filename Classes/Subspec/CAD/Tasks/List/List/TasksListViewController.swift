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

    fileprivate struct LayoutConstants {
        static let searchBarHeight: CGFloat = 32
        static let searchBarTopMargin: CGFloat = 10
    }

    open var viewModel: TasksListViewModel
    
    /// Delegate for UI events
    open weak var delegate: TasksListViewControllerDelegate?

    /// The refresh control for tasks list
    open private(set) var refreshControl: UIRefreshControl!

    /// The search bar for filtering tasks
    open private(set) var searchBar: UISearchBar!

    /// Observer for scroll bar movement
    private var scrollBarObservation: NSKeyValueObservation?

    /// The top constraint for the search bar
    private var searchBarTopConstraint: NSLayoutConstraint!

    /// Whether to ignore syncing the search bar to the collection view
    private var ignoreCollectionViewTracking: Bool = false

    public init(viewModel: TasksListViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    /// Override the layout class to adjust the content size
    open override func collectionViewLayoutClass() -> CollectionViewFormLayout.Type {
        return ScrollableCollectionViewFormLayout.self
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()

        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
        loadingManager.delegate = self
        
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

        // We can't add this to collection view for simpler scrolling, as the keyboard gets dismissed on any reload of data which makes noticeable performance issue (MPOLA-1289)
        view.addSubview(searchBar)

        // Prevent search bar going under header
        view.clipsToBounds = true

        // Use KVO to update search bar, rather than hijacking scroll delegate
        if let collectionView = collectionView {
            scrollBarObservation = collectionView.observe(\.contentOffset) { [unowned self] (view, change) in
                self.syncSearchBarWithCollectionView(collectionView)
            }
        }

        // Disable the inset manager, as it breaks things
        collectionViewInsetManager = nil
    }

    open func createConstraints() {
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: view.topAnchor)
        NSLayoutConstraint.activate([
            searchBarTopConstraint,
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchBar.heightAnchor.constraint(equalToConstant: LayoutConstants.searchBarHeight)
        ])
    }


    open override func construct(builder: FormBuilder) {
        if viewModel.otherSections.count > 0 {
            // Show header for my patrol group items (negative bottom margin to move up group items)
            builder += LargeTextHeaderFormItem()
                .text(StringSizing(string: viewModel.patrolGroupSectionTitle(), font: UIFont.systemFont(ofSize: 17, weight: .semibold), numberOfLines: 1))
                .layoutMargins(UIEdgeInsets(top: 24, left: 24, bottom: -24, right: 24))

            // Show my patrol group items
            constructGroup(builder: builder, sections: viewModel.sections)

            // Show header for other patrol group items
            builder += LargeTextHeaderFormItem()
                .text(StringSizing(string: viewModel.otherSectionTitle(), font: UIFont.systemFont(ofSize: 17, weight: .semibold), numberOfLines: 1))
                .layoutMargins(UIEdgeInsets(top: 24, left: 24, bottom: -24, right: 24))

            // Show other patrol group items
            constructGroup(builder: builder, sections: viewModel.otherSections)
        } else {
            // Just show my patrol group items without header
            constructGroup(builder: builder, sections: viewModel.sections)
        }
    }

    open func constructGroup(builder: FormBuilder, sections: [CADFormCollectionSectionViewModel<TasksListItemViewModel>]) {
        for (sectionIndex, section) in sections.enumerated() {
            let sectionCollapsible = viewModel.shouldShowExpandArrow() && !viewModel.indexesForNonCollapsibleSections.contains(sectionIndex)
            builder += HeaderFormItem(text: section.title.uppercased(),
                                      style: sectionCollapsible ? .collapsible : .plain)
            
            for item in section.items {
                let formItem: BaseFormItem
                if item is TasksListIncidentViewModel {
                    formItem = CustomFormItem(cellType: TasksListIncidentCollectionViewCell.self,
                                              reuseIdentifier: TasksListIncidentCollectionViewCell.defaultReuseIdentifier)
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
                        
                        if let viewModel = self?.viewModel(for: item) {
                            let vc = viewModel.createViewController()
                            self?.splitViewController?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
            }
        }
    }
    
    open func apply(theme: Theme, to cell: CollectionViewFormCell) {
        if let cell = cell as? TasksListIncidentCollectionViewCell {
            cell.apply(theme: theme)
        } else if let cell = cell as? TasksListResourceCollectionViewCell {
            cell.apply(theme: theme)
        } else if let cell = cell as? TasksListBasicCollectionViewCell {
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
        } else if let cell = cell as? TasksListBasicCollectionViewCell, let viewModel = viewModel as? TasksListBasicViewModel {
            cell.decorate(with: viewModel)
        }
    }
    
    open func syncSearchBarWithCollectionView(_ collectionView: UICollectionView) {
        guard !ignoreCollectionViewTracking else { return }

        // Position search bar relative to scrolled content
        let contentOffset = collectionView.contentOffset
        self.searchBarTopConstraint.constant = -contentOffset.y + LayoutConstants.searchBarTopMargin

        // If no longer scrolling and only showing partial search bar, show or hide it completely (like Mail app)
        if contentOffset.y > 0 && collectionView.isTracking {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if contentOffset == collectionView.contentOffset {
                    let searchOffset = LayoutConstants.searchBarHeight + LayoutConstants.searchBarTopMargin
                    if contentOffset.y > 0 && contentOffset.y < searchOffset {
                        // Ignore updates to content offset while animating show/hide
                        self.ignoreCollectionViewTracking = true
                        UIView.animate(withDuration: 0.3, animations: {
                            if contentOffset.y > searchOffset / 2 {
                                collectionView.contentOffset.y = searchOffset
                            } else {
                                collectionView.contentOffset.y = 0
                            }
                            self.searchBarTopConstraint.constant = -collectionView.contentOffset.y + LayoutConstants.searchBarTopMargin
                            self.view.layoutIfNeeded()
                        })
                        self.ignoreCollectionViewTracking = false
                    }
                }
            })
        }
    }

    // MARK: - Override

    open func reloadContent() {
        // Refresh the task list
        reloadForm()
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
        } else if let patrol = CADStateManager.shared.patrolsById[item.identifier] {
            return PatrolTaskItemViewModel(patrol: patrol)
        }

        return nil
    }

    // MARK: - CollectionViewDelegateFormLayout methods

    override open func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        // Make space for search bar using the form global header
        return viewModel.sections.isEmpty ? 0 : LayoutConstants.searchBarHeight
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
        let searchOffset = LayoutConstants.searchBarHeight + LayoutConstants.searchBarTopMargin
        if let collectionView = self.collectionView, collectionView.contentOffset.y < searchOffset {
            collectionView.contentOffset = CGPoint(x: 0, y: searchOffset)
        }
    }

    @objc open func refreshTasks() {
        delegate?.taskListDidPullToRefresh()
    }
}

extension TasksListViewController: LoadingStateManagerDelegate {
    public func loadingStateManager(_ stateManager: LoadingStateManager, didChangeState state: LoadingStateManager.State) {
        if state == .loaded && !searchBar.isFirstResponder {
            // Hide search bar when first loaded
            hideSearchBar()
        }
    }
}

extension TasksListViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        // Update loading state
        let noSections = (viewModel.numberOfSections() == 0)
        loadingManager.state = noSections ? .noContent : .loaded
        searchBar.isHidden = noSections && searchBar.text?.isEmpty == true

        // Reload content
        reloadContent()
    }
}

/// Custom form layout that adjust content size to enable scrolling search bar out of view, even if not enough content
/// to normally enable scrolling
fileprivate class ScrollableCollectionViewFormLayout: CollectionViewFormLayout {
    open override var collectionViewContentSize : CGSize {
        var size = super.collectionViewContentSize
        if let collectionView = collectionView {
            let minHeight = collectionView.frame.height +
                TasksListViewController.LayoutConstants.searchBarHeight +
                TasksListViewController.LayoutConstants.searchBarTopMargin
            size.height = max(size.height, minHeight)
        }
        return size
    }
}
