//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PatternKit
import PublicSafetyKit
// swiftlint:disable class_delegate_protocol
/// Delegate protocol for updating UI
public protocol TasksSplitViewModelDelegate: PopoverPresenter {
    /// Called when the sections data is updated
    func sectionsUpdated()
}
// swiftlint:enable class_delegate_protocol

open class TasksSplitViewModel {

    /// Delegate for UI updates
    open weak var delegate: TasksSplitViewModelDelegate?

    /// Container view model
    public let listContainerViewModel: TasksListContainerViewModel
    public let mapViewModel: TasksMapViewModel
    public let filterViewModel: TasksMapFilterViewModel

    public init(listContainerViewModel: TasksListContainerViewModel, mapViewModel: TasksMapViewModel, filterViewModel: TasksMapFilterViewModel) {
        self.listContainerViewModel = listContainerViewModel
        self.mapViewModel = mapViewModel
        self.filterViewModel = filterViewModel

        self.listContainerViewModel.splitViewModel = self
        self.mapViewModel.splitViewModel = self

        // Observe sync changes
        NotificationCenter.default.addObserver(self, selector: #selector(syncChanged), name: .CADSyncChanged, object: nil)
    }

    @objc open func syncChanged() {
        self.delegate?.sectionsUpdated()
    }

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let vc = TasksSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// Create the view controller for the master side of split view
    open func createMasterViewController() -> UIViewController {
        return listContainerViewModel.createViewController()
    }

    /// Create the view controller for the detail side of the split view
    open func createDetailViewController() -> UIViewController {
        return mapViewModel.createViewController()
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

    /// Title for the master view to be displayed in the segmented control
    open func masterSegmentTitle() -> String {
        return NSLocalizedString("List", comment: "Task list segment title")
    }

    /// Title for the detail view to be displayed in the segmented control
    open func detailSegmentTitle() -> String {
        return NSLocalizedString("Map", comment: "Map list segment title")
    }

    // MARK: - Filter

    /// Applies the filter to the map and task list
    open func applyFilter() {
        delegate?.dismiss(animated: true, completion: nil)
        mapViewModel.applyFilter()
        listContainerViewModel.applyFilter()

        // Set the bounding box for sync if showing outside patrol area
        if let boundingBox = mapViewModel.delegate?.boundingBox(), filterViewModel.showResultsOutsidePatrolArea {
            CADStateManager.shared.syncMode = .map(boundingBox: boundingBox)
        } else if let patrolGroup = CADStateManager.shared.patrolGroup {
            CADStateManager.shared.syncMode = .patrolGroup(patrolGroup: patrolGroup)
        } else {
            CADStateManager.shared.syncMode = .none
        }
    }
}

extension TasksSplitViewModel: MapFilterViewControllerDelegate {
    public func didSelectDone() {
        applyFilter()
    }
}
