//
//  TaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol TaskItemViewModelDelegate: class {
    func didUpdateModel()
}

open class TaskItemViewModel {

    open weak var delegate: (PopoverPresenter & TaskItemViewModelDelegate)?

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

    /// View controllers to show in the list
    open func detailViewControllers() -> [UIViewController] {
        return viewModels.map {
            $0.createDelegateViewController()
        }
    }
    
    /// The split view controller
    open var viewController: TaskItemSidebarSplitViewController?
    
    open var viewModels: [TaskDetailsViewModel]
    
    open func createViewController() -> UIViewController {
        MPLRequiresConcreteImplementation()
    }
    
    /// Init
    ///
    /// - Parameters:
    ///   - iconImage: Icon image to display in the header
    ///   - iconTintColor: Icon image color
    ///   - color: Color to use for the icon image background and status text
    ///   - statusText: Status text to display below the icon
    ///   - itemName: Name of the item
    public init(taskItemIdentifier: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?, subtitleText: String?, viewModels: [TaskDetailsViewModel] = []) {
        self.taskItemIdentifier = taskItemIdentifier
        self.iconImage = iconImage
        self.iconTintColor = iconTintColor
        self.color = color
        self.statusText = statusText
        self.itemName = itemName
        self.viewModels = viewModels
        self.subtitleText = subtitleText
        self.compactTitle = statusText
        self.compactSubtitle = subtitleText
        self.showCompactGlassBar = false
    }

    open func loadTask() -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }
    
    /// Called when the view model data should be refreshed from model data
    open func reloadFromModel() {
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
        MPLRequiresConcreteImplementation()
    }
}
