//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListContainerViewModel {

    // MARK: - Properties

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
                updateListData()
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel

        updateSourceItems()
        updateListData()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksListContainerViewController(viewModel: self)
    }

    // MARK: - Public methods

    /// Update the source items status
    public func updateSourceItems() {

        // TODO: populate counts from network
        sourceItems = SampleData.sourceItems()
        selectedSourceIndex = 0
    }

    /// Update the task list data
    public func updateListData() {

        // TODO: fetch from network
        switch selectedSourceIndex {
        case 0:
            listViewModel.sections = SampleData.incidents()
        default:
            listViewModel.sections = []
        }
    }
}

public class SampleData {

    static func sourceItems() -> [SourceItem] {
        let incidents = SourceItem(title: "Incidents", shortTitle: "INCI", state: .loaded(count: 6, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))
        let patrol = SourceItem(title: "Patrol", shortTitle: "PATR", state: .loaded(count: 1, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let broadcast = SourceItem(title: "Broadcast", shortTitle: "BCST", state: .loaded(count: 4, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let resources = SourceItem(title: "Resources", shortTitle: "RESO", state: .loaded(count: 9, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))

        return [incidents, patrol, broadcast, resources]
    }

    static func incidents() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "Responding to",
                                              items: [TasksListItemViewModel(title: "Assault (2)",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
                                                                             boxText: "P1",
                                                                             boxColor: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1),
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             boxText: "P2",
                                                                             boxColor: #colorLiteral(red: 0.9764705882, green: 0.8039215686, blue: 0.2745098039, alpha: 1),
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Trespassing (1)",
                                                                             subtitle: "16 Easey Street",
                                                                             caption: "AS4217  :  MP0001540",
                                                                             boxText: "P3",
                                                                             boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                             boxFilled: false)]),
            CADFormCollectionSectionViewModel(title: "2 Unassigned",
                                              items: [TasksListItemViewModel(title: "Vandalismn",
                                                                             subtitle: "12 Vere Street",
                                                                             caption: "AS4224  :  MP0001551",
                                                                             boxText: "P3",
                                                                             boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                             boxFilled: false),
                                                      TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             boxText: "P3",
                                                                             boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                             boxFilled: false)])
        ]
    }
}
