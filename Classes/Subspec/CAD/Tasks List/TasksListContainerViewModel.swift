//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Enum for all task types
public enum TaskListType: Int {
    case incident
    case patrol
    case broadcast
    case resource

    var title: String {
        switch self {
        case .incident:
            return NSLocalizedString("Incidents", comment: "Incidents navigation title")
        case .patrol:
            return NSLocalizedString("Patrol",    comment: "Patrol navigation title")
        case .broadcast:
            return NSLocalizedString("Broadcast", comment: "Broadcast navigation title")
        case .resource:
            return NSLocalizedString("Resources", comment: "Resources navigation title")
        }
    }

    var shortTitle: String {
        switch self {
        case .incident:
            return NSLocalizedString("INCI", comment: "Incidents short title")
        case .patrol:
            return NSLocalizedString("PATR", comment: "Patrol short title")
        case .broadcast:
            return NSLocalizedString("BCST", comment: "Broadcast short title")
        case .resource:
            return NSLocalizedString("RESO", comment: "Resources short title")
        }
    }
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    public weak var splitViewModel: TasksSplitViewModel?

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
        let type = TaskListType(rawValue: selectedSourceIndex)!
        listViewModel.sections = SampleData.sectionsForType(type)
    }
}

public class SampleData {

    static func sourceItemForType(type: TaskListType, count: UInt, color: UIColor) -> SourceItem {
        return SourceItem(title: type.title, shortTitle: type.shortTitle, state: .loaded(count: count, color: color))
    }

    static func sourceItems() -> [SourceItem] {
        return [
            sourceItemForType(type: .incident,  count: 6, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)),
            sourceItemForType(type: .patrol,    count: 1, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)),
            sourceItemForType(type: .broadcast, count: 4, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)),
            sourceItemForType(type: .resource,  count: 9, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1))
        ]
    }

    static func sectionsForType(_ type: TaskListType) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        switch type {
        case .incident:
            return SampleData.incidents()
        case .patrol:
            return SampleData.patrols()
        case .broadcast:
            return SampleData.broadcasts()
        case .resource:
            return SampleData.resources()
        }
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

    static func patrols() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Traffic Management",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)])
        ]
    }

    static func broadcasts() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Alert",
                                              items: [TasksListItemViewModel(title: "Impaired Driver",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "BC0997  :  10:16",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "1 Event",
                                              items: [TasksListItemViewModel(title: "Lawful Protest March",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0962  :  09:00 - 12:00",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "2 BOLF",
                                              items: [TasksListItemViewModel(title: "Vehicle: TNS448",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0995  :  1 day ago",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Vehicle: XNR106",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC1004  :  4 days ago",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)])
        ]
    }

    static func resources() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Duress",
                                              items: [TasksListItemViewModel(title: "P08 (2)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "In Duress 2:45",
                                                                             boxText: "P1",
                                                                             boxColor: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1),
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "7 Tasked",
                                              items: [TasksListItemViewModel(title: "P03 (3)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "Proceeding",
                                                                             boxText: "P1",
                                                                             boxColor: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1),
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "P12 (1)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "At Incident",
                                                                             boxText: "P1",
                                                                             boxColor: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1),
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "F05 (4)",
                                                                             subtitle: "Abbotsford",
                                                                             caption: "Processing",
                                                                             boxText: "P3",
                                                                             boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                             boxFilled: false),
                                                      TasksListItemViewModel(title: "K14 (2)",
                                                                             subtitle: "Collingwood",
                                                                             caption: "Processing",
                                                                             boxText: "P3",
                                                                             boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                             boxFilled: false)])
        ]
    }

}
