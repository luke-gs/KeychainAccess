//
//  TasksListHeaderViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol TasksListHeaderViewModelDelegate: class {
    func presentPopover(_ viewController: UIViewController, barButton: UIBarButtonItem?, animated: Bool)
}

/// View model for tasks list header view controller
open class TasksListHeaderViewModel {

    public weak var delegate: TasksListHeaderViewModelDelegate?

    /// The bar button items to display in header
    public var barButtonItems: [UIBarButtonItem]!

    public init() {
        let filterButton = UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showFilter))
        barButtonItems = [filterButton]
    }

    /// Create the view controller for this view model
    public func createRegularViewController() -> UIViewController {
        let vc = TasksListHeaderRegularViewController(viewModel: self)
        self.delegate = vc
        return vc
    }

    public func createCompactViewController() -> UIViewController {
        // TODO
        return UIViewController()
    }

    public func titleText() -> String {
        return NSLocalizedString("Incidents", comment: "Tasks list header title")
    }

    /// Shows the layer filter popover
    @objc private func showFilter() {
        // TODO
        // delegate?.presentPopover(vc, barButton: barButtonItems[0], animated: true)
    }
}
