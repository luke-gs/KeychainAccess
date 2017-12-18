//
//  TasksListHeaderViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol TasksListHeaderViewModelDelegate: PopoverPresenter {

    /// The source items have changed
    func sourceItemsChanged(_ sourceItems: [SourceItem])

    /// The selected source item has changed
    func selectedSourceItemChanged(_ selectedSourceIndex: Int)

    /// Present a popover from the given bar button item index
    func presentPopover(_ viewController: UIViewController, barButtonIndex: Int, animated: Bool)
}

/// View model for tasks list header view controller
open class TasksListHeaderViewModel {

    // MARK: - Properties

    /// Container view model used for keeping source items and selection in sync
    public var containerViewModel: TasksListContainerViewModel?

    /// Delegate for updating VC
    public weak var delegate: TasksListHeaderViewModelDelegate?

    /// The tasks source items
    public var sourceItems: [SourceItem] {
        get {
            return containerViewModel?.sourceItems ?? []
        }
        set {
            // Update container model and delegate VC
            containerViewModel?.sourceItems = newValue
            delegate?.sourceItemsChanged(newValue)
        }
    }

    /// The selected source item
    public var selectedSourceIndex: Int {
        get {
            return containerViewModel?.selectedSourceIndex ?? 0
        }
        set {
            // Update container model and delegate VC
            containerViewModel?.selectedSourceIndex = newValue
            delegate?.selectedSourceItemChanged(newValue)
        }
    }

    /// The bar button items to display in header
    public var barButtonItems: [UIBarButtonItem]!

    /// Compact header, created if needed
    public lazy var compactHeaderViewController: UIViewController = {
        return TasksListHeaderCompactViewController(viewModel: self)
    }()

    /// Regular header, created if needed
    public lazy var regularHeaderViewController: UIViewController = {
        return TasksListHeaderRegularViewController(viewModel: self)
    }()

    // MARK: - Initialization

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
        barButtonItems = [addButton]
    }

    // MARK: - Public methods

    public func titleText() -> String? {
        if let sourceItem = sourceItems[ifExists: selectedSourceIndex] {
            return sourceItem.title
        }
        return nil
    }

    // MARK: - Internal

    /// Shows the add new form sheet
    @objc private func showAdd() {
        // TODO
        // delegate?.presentFormSheet(vc, animated: true)
    }
}
