//
//  TasksListContainerViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Container view controller for showing task list, source bar and dynamic header
class TasksListContainerViewController: UIViewController {

    public let viewModel: TasksListContainerViewModel

    /// The list of tasks
    private var tasksListViewController: UIViewController!

    /// The header for title and nav items
    private var headerViewController: UIViewController? {
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
                view.addSubview(headerViewController.view)
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
    private var headerContainerView: UIView!

    /// The source bar used to choose task type
    private var sourceBar: SourceBar!

    /// The source bar inset manager
    private var sourceInsetManager: ScrollViewInsetManager?

    /// Constraint for making source bar have no height
    private var sourceBarHiddenConstraint: NSLayoutConstraint?

    /// The current sources available to display
    public var sourceItems: [SourceItem] = [] {
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
    public var selectedSourceIndex: Int? = nil {
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
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .map), style: .plain, target: self, action: #selector(toggleFullScreen))
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()
        updateFromViewModel()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Fix top margin of source bar
        sourceInsetManager?.standardContentInset    = .zero
        sourceInsetManager?.standardIndicatorInset  = .zero
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateConstraintsForSizeChange()
    }

    public func createSubviews() {
        let sourceBackground = GradientView(frame: .zero)
        sourceBackground.gradientColors = [.black, .sidebarBlack]

        // Add source bar
        sourceBar = SourceBar(frame: .zero)
        sourceBar.backgroundView = sourceBackground
        sourceBar.sourceBarDelegate = self
        sourceBar.items = sourceItems
        sourceBar.selectedIndex = selectedSourceIndex
        view.addSubview(sourceBar)

        // Use inset manager to fix top margin
        sourceInsetManager = ScrollViewInsetManager(scrollView: sourceBar)

        // Add container for header
        headerContainerView = UIView(frame: .zero)
        view.addSubview(headerContainerView)

        // Add task list
        tasksListViewController = viewModel.listViewModel.createViewController()
        addChildViewController(tasksListViewController)
        view.addSubview(tasksListViewController.view)
        tasksListViewController.didMove(toParentViewController: self)
        
    }
    
    @objc public func toggleFullScreen() {
        guard let splitViewController = pushableSplitViewController else { return }
        
        let width = isFullScreen ? UISplitViewControllerAutomaticDimension : splitViewController.view.bounds.width
        
        UIView.animate(withDuration: 0.3) {
            splitViewController.embeddedSplitViewController.minimumPrimaryColumnWidth = width
            splitViewController.embeddedSplitViewController.maximumPrimaryColumnWidth = width
        }
        isFullScreen = !isFullScreen

    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isFullScreen, let splitViewController = self.pushableSplitViewController {
                let width = splitViewController.view.bounds.width
                splitViewController.embeddedSplitViewController.minimumPrimaryColumnWidth = width
                splitViewController.embeddedSplitViewController.maximumPrimaryColumnWidth = width
            }
        }, completion: nil)
    }
    
    

    public func createConstraints() {
        // Layout sidebar on left, header on top right, list bottom right
        let listView = tasksListViewController.view!

        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        listView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false

        sourceBarHiddenConstraint = sourceBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            sourceBar.topAnchor.constraint(equalTo: view.topAnchor),
            sourceBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sourceBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerContainerView.topAnchor.constraint(equalTo: safeAreaOrLayoutGuideTopAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            listView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            listView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // We need to use viewWillTransition here, as master VC is not told about all trait collection changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            if self.isFullScreen, let splitViewController = self.pushableSplitViewController {
                let width = splitViewController.view.bounds.width
                splitViewController.embeddedSplitViewController.minimumPrimaryColumnWidth = width
                splitViewController.embeddedSplitViewController.maximumPrimaryColumnWidth = width
            }
            self.updateConstraintsForSizeChange()
            }, completion: nil)
    }

    open func updateConstraintsForSizeChange() {
        if let traitCollection = splitViewController?.traitCollection {
            let compact = (traitCollection.horizontalSizeClass == .compact)

            // Hide source bar if compact
            self.sourceBarHiddenConstraint?.isActive = compact

            // Set user interface style based on whether compact
            if let tasksListViewController = tasksListViewController as? FormCollectionViewController {
                tasksListViewController.userInterfaceStyle = compact ? .current : .dark
            }

            // Replace header with one for size class
            headerViewController = viewModel.headerViewModel.createViewController(compact: compact)
        }
    }

    // MARK: - Data model

    public func updateFromViewModel() {
        sourceItems = viewModel.sourceItems
        selectedSourceIndex = viewModel.selectedSourceIndex
    }
}

// MARK: - SourceBarDelegate
extension TasksListContainerViewController: SourceBarDelegate {

    public func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int) {
        selectedSourceIndex = index
        viewModel.selectedSourceIndex = index
    }

    public func sourceBar(_ bar: SourceBar, didRequestToLoadItemAt index: Int) {
    }
}

