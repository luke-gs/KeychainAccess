//
//  TasksListContainerViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Container view controller for showing task list, source bar and dynamic header
open class TasksListContainerViewController: UIViewController, LoadableViewController {

    open let viewModel: TasksListContainerViewModel

    /// The loading state manager for when tasks are being loaded
    open let loadingManager: LoadingStateManager = LoadingStateManager()

    /// The content view that is shown once data is loaded
    open let contentView: UIView = UIView(frame: .zero)

    /// The list of tasks
    open private(set) var tasksListViewController: TasksListViewController!

    /// The header for title and nav items
    open var headerViewController: UIViewController? {
        didSet {
            guard oldValue != headerViewController else { return }

            // Cleanup old value
            if let oldValue = oldValue {
                oldValue.removeFromParentViewController()
                oldValue.view.removeFromSuperview()
            }

            // Add the new header view controller as a child
            if let headerViewController = headerViewController {
                addChildViewController(headerViewController)
                headerContainerView.addSubview(headerViewController.view)
                headerViewController.didMove(toParentViewController: self)

                // Constrain header to top
                let headerView = headerViewController.view!
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
                    headerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
                ])
            }
            view.setNeedsLayout()
        }
    }
    
    public private(set) var isFullScreen: Bool = false

    /// A container view for the header, so layout can be applied relative to it
    open private(set) var headerContainerView: UIView!

    /// The source bar used to choose task type
    open private(set) var sourceBar: SourceBar!

    /// The source bar inset manager
    open private(set) var sourceInsetManager: ScrollViewInsetManager!

    /// Constraint for making source bar have no height
    private var sourceBarWidthConstraint: NSLayoutConstraint!

    /// Button for toggling full screen
    private var fullScreenButton: UIBarButtonItem {
        let image = AssetManager.shared.image(forKey: isFullScreen ? .map : .list)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleFullScreen))
    }

    /// Button for showing map layer filter
    private var filterButton: UIBarButtonItem {
        var image = AssetManager.shared.image(forKey: .filter)
        if let filterViewModel = viewModel.splitViewModel?.filterViewModel, !filterViewModel.isDefaultState {
            image = AssetManager.shared.image(forKey: .filterFilled)
        }
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showMapLayerFilter))
    }

    /// The current sources available to display
    open var sourceItems: [SourceItem] = [] {
        didSet {
            viewIfLoaded?.setNeedsLayout()
            sourceBar?.items = sourceItems

            if let selectedSourceIndex = selectedSourceIndex,
                selectedSourceIndex >= sourceItems.count {
                self.selectedSourceIndex = nil
            } else {
                sourceBar?.selectedIndex = selectedSourceIndex
            }
        }
    }

    /// The selected source index.
    open var selectedSourceIndex: Int? = nil {
        didSet {
            if let selectedSourceIndex = selectedSourceIndex {
                precondition(selectedSourceIndex < sourceItems.count)
            }
            sourceBar?.selectedIndex = selectedSourceIndex
        }
    }

    // MARK: - Initializers

    public init(viewModel: TasksListContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        updateNavigationButtons()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()
        updateSourceItems()
        
        if viewModel.allowsSwipeToExpand() {
            setupSwipeGestureRecognizers()
        }
    }
    
    open func setupSwipeGestureRecognizers() {
        // Swipe right to expand the list
        let expandGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        expandGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(expandGestureRecognizer)
        
        // Swipe left to contract the list
        let contractGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        contractGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(contractGestureRecognizer)
    }

    @objc func didSwipeLeft() {
        if isFullScreen {
            toggleFullScreen()
        }
    }
    
    @objc func didSwipeRight() {
        if !isFullScreen {
            toggleFullScreen()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Fix top margin of source bar
        sourceInsetManager.standardContentInset    = .zero
        sourceInsetManager.standardIndicatorInset  = .zero
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateConstraintsForSizeChange()

        // Update view model based on current state
        viewModel.updateSections()
    }

    open func createSubviews() {
        view.addSubview(contentView)

        let sourceBackground = GradientView(frame: .zero)
        sourceBackground.gradientColors = [.black, .sidebarBlack]

        // Add source bar
        sourceBar = SourceBar(frame: .zero)
        sourceBar.backgroundView = sourceBackground
        sourceBar.sourceBarDelegate = self
        sourceBar.items = sourceItems
        sourceBar.selectedIndex = selectedSourceIndex
        contentView.addSubview(sourceBar)

        // Use inset manager to fix top margin
        sourceInsetManager = ScrollViewInsetManager(scrollView: sourceBar)

        // Add container for header
        headerContainerView = UIView(frame: .zero)
        contentView.addSubview(headerContainerView)

        // Add task list
        tasksListViewController = viewModel.listViewModel.createViewController()
        addChildViewController(tasksListViewController, toView: contentView)
        tasksListViewController.delegate = self

        // Set base view color for when content is not shown
        view.backgroundColor = tasksListViewController.view.backgroundColor

        // Configure loading state
        loadingManager.baseView = view
        loadingManager.contentView = contentView
        loadingManager.loadingView.titleLabel.textColor = .white
        loadingManager.loadingView.titleLabel.text = viewModel.loadingTitle()
        loadingManager.loadingView.subtitleLabel.text = viewModel.loadingSubtitle()

        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
    }
    
    open func createConstraints() {

        contentView.translatesAutoresizingMaskIntoConstraints = false
        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false

        let listView = tasksListViewController.view!
        listView.translatesAutoresizingMaskIntoConstraints = false

        sourceBarWidthConstraint = sourceBar.widthAnchor.constraint(equalToConstant: 64)

        // Layout sidebar on left, header on top right, list bottom right
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sourceBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sourceBarWidthConstraint,

            headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            listView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            listView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            listView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // We need to use viewWillTransition here, as master VC is not told about all trait collection changes
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            self.updateConstraintsForSizeChange()
            self.updateNavigationButtons()
            }, completion: nil)
    }
    
    open func updateConstraintsForSizeChange() {
        if let traitCollection = splitViewController?.traitCollection {
            let compact = (traitCollection.horizontalSizeClass == .compact)

            // Hide source bar if compact
            sourceBarWidthConstraint.constant = compact ? 0 : 64

            // Set user interface style based on whether compact
            tasksListViewController.userInterfaceStyle = compact ? .current : .dark

            // Replace header with one for size class
            headerViewController = viewModel.headerViewModel.createViewController(compact: compact)
        }
    }
    
    @objc public func toggleFullScreen() {
        guard let splitViewController = pushableSplitViewController as? TasksSplitViewController else { return }
        let width = isFullScreen ? TasksSplitViewController.defaultSplitWidth : splitViewController.view.bounds.width
        splitViewController.setMasterWidth(width, animated: true)
        
        // Tell VC that we have toggled
        isFullScreen = !isFullScreen

        updateNavigationButtons()
    }

    @objc public func showMapLayerFilter() {
        present(TaskListScreen.mapFilter(delegate: viewModel.splitViewModel))
    }
    
    open func updateNavigationButtons() {
        let buttons = UIViewController.isWindowCompact() ?
            [filterButton] : isFullScreen ?
                [filterButton, fullScreenButton] : [fullScreenButton]
        navigationItem.rightBarButtonItems = buttons
    }

    open func refreshTasks() {
        // Refresh the task list from the network
        firstly {
            return viewModel.refreshTaskList()
        }.ensure { [weak self] in
            self?.tasksListViewController.refreshControl.endRefreshing()
        }.catch { error in
            AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
        }
    }
}

// MARK: - TasksListContainerViewModelDelegate
extension TasksListContainerViewController: TasksListContainerViewModelDelegate {
    open func updateSourceItems() {
        sourceItems = viewModel.sourceItems
        selectedSourceIndex = viewModel.selectedSourceIndex

        // Update filter button
        updateNavigationButtons()
    }

    open func updateSelectedSourceIndex() {
        selectedSourceIndex = viewModel.selectedSourceIndex

        // Reset to top and cancel search when switching source types
        tasksListViewController.collectionView?.contentOffset = .zero
        tasksListViewController.hideSearchBar()
    }
}

// MARK: - SourceBarDelegate
extension TasksListContainerViewController: SourceBarDelegate {

    open func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int) {
        selectedSourceIndex = index
        viewModel.selectedSourceIndex = index
    }

    open func sourceBar(_ bar: SourceBar, didRequestToLoadItemAt index: Int) {
    }
}

extension TasksListContainerViewController: TasksListViewControllerDelegate {
    public func taskListDidPullToRefresh() {
        refreshTasks()
    }

    public func taskListDidChangeSearchText(searchText: String) {
        viewModel.searchText = searchText
    }
}
