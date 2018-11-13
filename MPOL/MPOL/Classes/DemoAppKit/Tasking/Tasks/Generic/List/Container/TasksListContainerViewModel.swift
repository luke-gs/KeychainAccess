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
import PatternKit

/// Protocol for notifying UI of updated view model data
public protocol TasksListContainerViewModelDelegate: class {

    /// Called when the filter is changed
    func filterChanged()

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
    public let headerViewModel: TasksListHeaderViewModel
    public let listViewModel: TasksListViewModel

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
                delegate?.updateSourceItems()
            }
        }
    }

    /// The selected source index
    open var selectedSourceIndex: Int = 0 {
        didSet {
            if selectedSourceIndex != oldValue {
                selectedSourceIndexChanged()
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel
        self.listViewModel.containerViewModel = self

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

    /// Whether swiping allows the map to expand and contract
    open func allowsSwipeToExpand() -> Bool {
        return false
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
        return CADStateManager.shared.syncDetails()
    }

    /// Applies the filter to the map
    open func applyFilter() {
        updateSections()
        delegate?.filterChanged()
    }

    /// Update the task list data
    open func updateSections() {
        let type = CADClientModelTypes.taskListSources.allCases[selectedSourceIndex]

        if let splitViewModel = splitViewModel {
            // Update the task list view model sections
            let listContent = type.sectionedListContent(filterViewModel: splitViewModel.filterViewModel, searchText: searchText)

            // If list content contains more than 1 array, set other sections on list
            // We set otherSections before sections as UI updates are triggered when sections prop changes
            if listContent.count > 1 {
                listViewModel.otherSections = listContent[1]
            } else {
                listViewModel.otherSections = []
            }
            listViewModel.sections = listContent.first ?? []

            // Update the source items
            sourceItems = CADClientModelTypes.taskListSources.allCases.map {
                return $0.sourceItem(filterViewModel: splitViewModel.filterViewModel)
            }
        } else {
            // No state yet
            listViewModel.sections = []
            sourceItems = [SourceItem(title: "", state: .loading)]
        }
    }

    open func selectedSourceIndexChanged() {
        let type = CADClientModelTypes.taskListSources.allCases[selectedSourceIndex]

        headerViewModel.selectedSourceIndex = selectedSourceIndex
        splitViewModel?.mapViewModel.loadTasks()
        if let annotationType = type.annotationViewType {
            splitViewModel?.mapViewModel.priorityAnnotationType = annotationType
        }
        updateSections()

        // Show/hide add button
        headerViewModel.setAddButtonVisible(type.canCreate)

        delegate?.updateSelectedSourceIndex()
    }
}
