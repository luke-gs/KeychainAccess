//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Delegate protocol for updating UI
public protocol TasksSplitViewModelDelegate: PopoverPresenter {
    /// Called when the sections data is updated
    func sectionsUpdated()
}


open class TasksSplitViewModel {

    /// Delegate for UI updates
    open weak var delegate: TasksSplitViewModelDelegate?

    /// Container view model
    public let listContainerViewModel: TasksListContainerViewModel
    public let mapViewModel: TasksMapViewModel
    public let filterViewModel: TaskMapFilterViewModel

    public init(listContainerViewModel: TasksListContainerViewModel, mapViewModel: TasksMapViewModel, filterViewModel: TaskMapFilterViewModel) {
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
    public func createViewController() -> UIViewController {
        let vc = TasksSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// Create the view controller for the master side of split view
    public func createMasterViewController() -> UIViewController {
        return listContainerViewModel.createViewController()
    }

    /// Create the view controller for the detail side of the split view
    public func createDetailViewController() -> UIViewController {
        return mapViewModel.createViewController()
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }
    
    /// Title for the master view to be displayed in the segmented control
    public func masterSegmentTitle() -> String {
        return NSLocalizedString("List", comment: "Task list segment title")
    }
    
    /// Title for the detail view to be displayed in the segmented control
    public func detailSegmentTitle() -> String {
        return NSLocalizedString("Map", comment: "Map list segment title")
    }
    
    /// Shows the map filter popup
    public func presentMapFilter() {
        let viewController = filterViewModel.createViewController(delegate: self)
        delegate?.presentFormSheet(viewController, animated: true)
    }
    
    /// Applies the filter to the map and task list
    public func applyFilter() {
        delegate?.dismiss(animated: true, completion: nil)
        mapViewModel.applyFilter()
        listContainerViewModel.updateSections()
    }

}


extension TasksSplitViewModel: MapFilterViewControllerDelegate {
    public func didSelectDone() {
        applyFilter()
    }
}
