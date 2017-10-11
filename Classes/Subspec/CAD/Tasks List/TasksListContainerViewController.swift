//
//  TasksListContainerViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Container view controller for showing task list, source bar and header
class TasksListContainerViewController: UIViewController {

    /// The same view model as the split
    public let viewModel: TasksSplitViewModel

    /// The list of tasks
    private var tasksListViewController: UIViewController!

    /// The header for title and nav items
    private var headerViewController: UIViewController!

    /// The source bar used to choose task type
    private var sourceBar: SourceBar!

    private var sourceInsetManager: ScrollViewInsetManager?

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

    public init(viewModel: TasksSplitViewModel) {
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

    public func createSubviews() {
        let sidebarColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
        let sourceBackground = GradientView(frame: .zero)
        sourceBackground.gradientColors = [#colorLiteral(red: 0.05098039216, green: 0.05490196078, blue: 0.06274509804, alpha: 1), sidebarColor]

        // Add source bar
        sourceBar = SourceBar(frame: .zero)
        sourceBar.backgroundView = sourceBackground
        sourceBar.sourceBarDelegate = self
        sourceBar.items = sourceItems
        sourceBar.selectedIndex = selectedSourceIndex
        view.addSubview(sourceBar)

        // Use inset manager to fix top margin
        sourceInsetManager = ScrollViewInsetManager(scrollView: sourceBar)

        // Add child VCs
        headerViewController = viewModel.tasksListHeaderViewModel.createRegularViewController()
        addChildViewController(headerViewController)
        view.addSubview(headerViewController.view)
        headerViewController.didMove(toParentViewController: self)

        tasksListViewController = viewModel.createTasksListViewController()
        addChildViewController(tasksListViewController)
        view.addSubview(tasksListViewController.view)
        tasksListViewController.didMove(toParentViewController: self)
    }

    public func createConstraints() {
        // Layout sidebar on left, header on top right, list bottom right
        let headerView = headerViewController.view!
        let listView = tasksListViewController.view!

        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        listView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sourceBar.topAnchor.constraint(equalTo: view.topAnchor),
            sourceBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sourceBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            listView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            listView.leadingAnchor.constraint(equalTo: sourceBar.trailingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    public func updateFromViewModel() {
        sourceItems = viewModel.tasksListViewModel.sourceItems
        if !sourceItems.isEmpty {
            selectedSourceIndex = 0
        }
    }
}

// MARK: - SourceBarDelegate
extension TasksListContainerViewController: SourceBarDelegate {

    public func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int) {
        selectedSourceIndex = index
        // delegate?.sidebarViewController(self, didSelectSourceAt: index)
    }

    public func sourceBar(_ bar: SourceBar, didRequestToLoadItemAt index: Int) {
    }
}

