//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListContainerViewModel {

    // Child view models
    public let headerViewModel: TasksListHeaderViewModel
    public let listViewModel: TasksListViewModel

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    public var sourceItems: [SourceItem] = [] {
        didSet {
            if sourceItems != oldValue {
                headerViewModel.sourceItems = sourceItems
            }
        }
    }

    /// The selected source index
    public var selectedSourceIndex: Int = 0 {
        didSet {
            if selectedSourceIndex != oldValue {
                headerViewModel.selectedSourceIndex = selectedSourceIndex
            }
        }
    }

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {
        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel
        updateSourceItems()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksListContainerViewController(viewModel: self)
    }

    /// Update the source items status
    public func updateSourceItems() {

        // TODO: populate counts from network
        let incidents = SourceItem(title: "Incidents", shortTitle: "INCI", state: .loaded(count: 6, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))
        let patrol = SourceItem(title: "Patrol", shortTitle: "PATR", state: .loaded(count: 1, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let broadcast = SourceItem(title: "Broadcast", shortTitle: "BCST", state: .loaded(count: 4, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let resources = SourceItem(title: "Resources", shortTitle: "RESO", state: .loaded(count: 9, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))

        sourceItems = [incidents, patrol, broadcast, resources]
        selectedSourceIndex = 0
    }
}

