//
//  TaskDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Type alias for a task view model delegate
public typealias TaskDetailsViewController = UIViewController & CADFormCollectionViewModelDelegate

/// Protocol for all task details view models
public protocol TaskDetailsViewModel: class {

    /// Delegate for UI updates
    var delegate: CADFormCollectionViewModelDelegate? {get set}

    /// Create view controller for the view model
    func createViewController() -> TaskDetailsViewController

    /// Reload the content of view model from data model
    func reloadFromModel()
}

extension TaskDetailsViewModel {
    // Convenience
    public func createDelegateViewController() -> TaskDetailsViewController {
        let detailViewController = createViewController()
        delegate = detailViewController
        return detailViewController
    }
}


