//
//  TasksListContainerViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Container view controller for showing task list, source bar and dynamic header
open class TasksListContainerViewController: UIViewController, LoadableViewController {

    open let viewModel: TasksListContainerViewModel

    /// The loading state manager for when tasks are being loaded
    open let loadingManager: LoadingStateManager = LoadingStateManager()

    /// The content view that is shown once data is loaded
    open let contentView: UIView = UIView(frame: .zero)

    /// The list of tasks
    open private(set) var tasksListViewController: UIViewController!

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

    /// A container view for the header, so layout can be applied relative to it
    open private(set) var headerContainerView: UIView!

    /// The source bar used to choose task type
    open private(set) var sourceBar: SourceBar!

    /// The source bar inset manager
    open private(set) var sourceInsetManager: ScrollViewInsetManager?

    /// Constraint for making source bar have no height
    private var sourceBarHiddenConstraint: NSLayoutConstraint?

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

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateConstraintsForSizeChange()
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
        addChildViewController(tasksListViewController)
        contentView.addSubview(tasksListViewController.view)
        tasksListViewController.didMove(toParentViewController: self)

        view.backgroundColor = tasksListViewController.view.backgroundColor

        // Configure loading state
        loadingManager.baseView = view
        loadingManager.contentView = contentView
        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle()
    }

    open func createConstraints() {

        contentView.translatesAutoresizingMaskIntoConstraints = false
        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false

        let listView = tasksListViewController.view!
        listView.translatesAutoresizingMaskIntoConstraints = false

        sourceBarHiddenConstraint = sourceBar.widthAnchor.constraint(equalToConstant: 0)

        // Layout sidebar on left, header on top right, list bottom right
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sourceBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            listView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            listView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            listView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    // We need to use viewWillTransition here, as master VC is not told about all trait collection changes
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
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

    open func updateFromViewModel() {
        sourceItems = viewModel.sourceItems
        selectedSourceIndex = viewModel.selectedSourceIndex
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

