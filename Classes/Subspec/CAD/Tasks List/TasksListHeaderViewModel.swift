//
//  TasksListHeaderViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol TasksListHeaderViewModelDelegate: PopoverPresenter {
    func presentPopover(_ viewController: UIViewController, barButtonIndex: Int, animated: Bool)
}

/// View model for tasks list header view controller
open class TasksListHeaderViewModel {

    public weak var delegate: TasksListHeaderViewModelDelegate?

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    public var sourceItems: [SourceItem] = []

    /// The bar button items to display in header
    public var barButtonItems: [UIBarButtonItem]!

    public lazy var compactHeaderViewController: UIViewController = {
        return TasksListHeaderCompactViewController(viewModel: self)
    }()

    public lazy var regularHeaderViewController: UIViewController = {
        return TasksListHeaderRegularViewController(viewModel: self)
    }()

    public init() {
        createBarButtonItems()
    }

    /// Create the view controller for this view model
    public func createViewController(compact: Bool) -> UIViewController {
        let vc: UIViewController = compact ? compactHeaderViewController : regularHeaderViewController
        if let vc = vc as? TasksListHeaderViewModelDelegate {
            self.delegate = vc
        }
        return vc
    }

    /// Create the bar button items for header
    public func createBarButtonItems() {
        let addButton = UIBarButtonItem(image: AssetManager.shared.image(forKey: .add), style: .plain, target: self, action: #selector(showAdd))
        let filterButton = UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: self, action: #selector(showFilter))
        barButtonItems = [addButton, filterButton]
    }

    public func titleText() -> String {
        return NSLocalizedString("Incidents", comment: "Tasks list header title")
    }

    /// Shows the add new form sheet
    @objc private func showAdd() {
        // TODO
        // delegate?.presentFormSheet(vc, animated: true)
    }

    /// Shows the layer filter popover
    @objc private func showFilter() {
        // TODO
        delegate?.presentPopover(UIViewController(), barButtonIndex: 1, animated: true)
    }

}
