//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksSplitViewModel {

    /// Container view model
    public let listContainerViewModel: TasksListContainerViewModel
    public let mapViewModel: TasksMapViewModel
    public let filterViewModel: TaskMapFilterViewModel
    public weak var presenter: (PopoverPresenter & MapFilterViewControllerDelegate)?

    public init(listContainerViewModel: TasksListContainerViewModel, mapViewModel: TasksMapViewModel, filterViewModel: TaskMapFilterViewModel) {
        self.listContainerViewModel = listContainerViewModel
        self.mapViewModel = mapViewModel
        self.filterViewModel = filterViewModel
        
        self.listContainerViewModel.splitViewModel = self
        self.mapViewModel.splitViewModel = self
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = TasksSplitViewController(viewModel: self)
        presenter = vc
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
    
    public func presentMapFilter() {
        if let viewController = filterViewModel.createViewController() as? MapFilterViewController {
            viewController.delegate = presenter
            presenter?.presentFormSheet(viewController, animated: true)
        }
        
    }
    
    public func applyFilter() {
        // TODO: Logic
        print("Applying filter")
        presenter?.dismiss(animated: true, completion: nil)
        mapViewModel.applyFilter()
    }

}
