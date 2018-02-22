//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import MapKit

/// Protocol for notifying UI of updated view model data
public protocol TasksListContainerViewModelDelegate: class {

    // Called when source items are updated
    func updateSourceItems()

    // Called when selected source changes
    func updateSelectedSourceIndex()
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksListContainerViewModelDelegate?

    // MARK: - Properties
    
    // Child view models
    open let headerViewModel: TasksListHeaderViewModel
    open let listViewModel: TasksListViewModel

    /// The search filter text
    open var searchText: String? {
        didSet {
            if searchText != oldValue {
                updateSections()
            }
        }
    }

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    open var sourceItems: [SourceItem] = [] {
        didSet {
            if sourceItems != oldValue {
                headerViewModel.sourceItems = sourceItems
            }
        }
    }

    /// The selected source index
    open var selectedSourceIndex: Int = 0 {
        didSet {
            if selectedSourceIndex != oldValue {
                let type = CADClientModelTypes.taskListSources.init(rawValue: selectedSourceIndex)

                headerViewModel.selectedSourceIndex = selectedSourceIndex
                splitViewModel?.mapViewModel.loadTasks()
                if let annotationType = type?.annotationViewType {
                    splitViewModel?.mapViewModel.priorityAnnotationType = annotationType
                }
                updateSections()

                // Show/hide add button
                headerViewModel.setAddButtonVisible((type?.canCreate).isTrue)

                delegate?.updateSelectedSourceIndex()
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel

        updateSections()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self

        // Observe sync changes
        NotificationCenter.default.addObserver(self, selector: #selector(syncChanged), name: .CADSyncChanged, object: nil)
        
        /// Observe book-on and callsign changes to show assigned incidents
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADBookOnChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADCallsignChanged, object: nil)

    }

    @objc open func syncChanged() {
        updateSections()
    }
    
    @objc open func bookOnChanged() {
        updateSections()
    }

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let vc = TasksListContainerViewController(viewModel: self)
        delegate = vc
        return vc
    }

    // MARK: - Public methods

    /// Content title shown when no results
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Tasks Found", comment: "")
    }

    open func noContentSubtitle() -> String? {
        return nil
    }

    open func loadingTitle() -> String? {
        return NSLocalizedString("Please wait", comment: "")
    }

    open func loadingSubtitle() -> String? {
        return NSLocalizedString("We’re retrieving your tasks now", comment: "")
    }

    // Refresh all tasks list data
    open func refreshTaskList() -> Promise<Void> {
        return CADStateManager.shared.syncDetails().then { _ -> Void in
        }
    }

    // MARK: - Internal methods

    /// Update the task list data
    open func updateSections() {
        let type = CADClientModelTypes.taskListSources.init(rawValue: selectedSourceIndex)!

        if let splitViewModel = splitViewModel {
            // Update the task list view model sections
            type.updateListContent(listViewModel: listViewModel, filterViewModel: splitViewModel.filterViewModel)

            // Update the source items status
            sourceItems = CADClientModelTypes.taskListSources.allCases.map {
                return $0.sourceItem(filterViewModel: splitViewModel.filterViewModel)
            }
        } else {
            listViewModel.sections = []
            sourceItems = CADClientModelTypes.taskListSources.allCases.map {
                return SourceItem(title: $0.title, shortTitle: $0.shortTitle, state: .loaded(count: UInt(0), color: .secondaryGray))
            }
        }
        delegate?.updateSourceItems()
    }

}
