//
//  TaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol TaskItemViewModelDelegate: PopoverPresenter {
    func didUpdateModel()
    func setLoadingState(_ state: LoadingStateManager.State)
    func setLoadingState(_ state: LoadingStateManager.State, error: Error?)
}

open class TaskItemViewModel {

    open weak var delegate: TaskItemViewModelDelegate?

    /// The last time the details object was loaded from the network
    open var lastDetailLoadTime: Date?

    /// The task item details that have been loaded
    open var taskItemDetails: CADTaskListItemModelType?

    /// The identifier for the task item
    open var taskItemIdentifier: String

    /// The navigation title for this type of task item details
    open var navTitle: String?

    /// The navigation title for this type of task item details when compact
    open var compactNavTitle: String?

    /// Icon image to display in the header
    open var iconImage: UIImage?

    /// Icon image color (not the background!)
    open var iconTintColor: UIColor?

    /// Color to use for the icon image background and status text
    open var color: UIColor?

    /// Status text to display below the icon (e.g. 'In Duress')
    open var statusText: String?

    /// Name of the item (e.g. 'P08')
    open var itemName: String?

    /// Text for the caption to display below the item name
    open var subtitleText: String?

    /// Whether to show the glass bar overlay that allows changing sidebar state in compact mode
    open var showCompactGlassBar: Bool

    /// The compact title shown in compact glass bar (e.g. 'Currently Resourced')
    open var compactTitle: String?

    /// The compact subtitle shown in compact glass bar (e.g. 'Respond to this incident')
    open var compactSubtitle: String?

    /// The text to show for the last update
    open func lastUpdatedText() -> String? {
        if let lastDetailLoadTime = lastDetailLoadTime?.elapsedTimeIntervalForHuman() {
            return "Updated \(lastDetailLoadTime)"
        } else if let syncTimeString = CADStateManager.shared.lastSyncTime?.elapsedTimeIntervalForHuman() {
            return "Updated \(syncTimeString)"
        }
        return nil
    }

    /// View controllers to show in the list
    open func detailViewControllers() -> [UIViewController] {
        return viewModels.map {
            $0.createDelegateViewController()
        }
    }

    /// The sidebar detail view models
    open private(set) lazy var viewModels: [TaskDetailsViewModel] = {
        return createViewModels()
    }()

    open func createViewModels() -> [TaskDetailsViewModel] {
        MPLRequiresConcreteImplementation()
    }

    open func createViewController() -> UIViewController {
        MPLRequiresConcreteImplementation()
    }

    public init(taskItemIdentifier: String) {
        self.taskItemIdentifier = taskItemIdentifier
        self.showCompactGlassBar = false
    }

    open func loadTask() -> Promise<Void> {
        delegate?.setLoadingState(.loading)
        return firstly {
            return loadTaskItem()
        }.then { [weak self] item -> Promise<Void> in
            self?.delegate?.setLoadingState(.loaded)
            self?.taskItemDetails = item
            self?.reloadFromModel()
            return Promise<Void>()
        }
    }

    open func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        MPLRequiresConcreteImplementation()
    }

    /// Called when the view model data should be refreshed from model data
    open func reloadFromModel() {
        delegate?.didUpdateModel()
    }

    /// Called when a user taps the task status of a task item
    open func didTapTaskStatus() {
        // Do nothing by default
    }

    /// Called to see if changing resource status is allowed
    open func allowChangeResourceStatus() -> Bool {
        return false
    }

    // Called when a user pulls to refresh on the sidebar
    open func refreshTask() -> Promise<Void> {
        return loadTask()
    }
}
