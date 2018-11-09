//
//  CADTaskListSourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
/// Protocol for an enum representing a source of items in the task list
/// eg Incidents, Resources, Patrols, Broadcasts, KALOFs
public protocol CADTaskListSourceType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADTaskListSourceType] { get }

    /// The case used for incident specific UI
    static var incidentCase: CADTaskListSourceType { get }

    /// The case used for resource specific UI
    static var resourceCase: CADTaskListSourceType { get }

    // MARK: - Raw value

    // Enum init
    init?(rawValue: Int)

    /// Enum raw value
    var rawValue: Int { get }

    // MARK: - Methods

    /// The default title to show
    var title: String { get }

    /// The short title to show in the source bar
    var shortTitle: String { get }

    /// Return the source bar item of this type based on the current filter
    func sourceItem(filterViewModel: TasksMapFilterViewModel) -> SourceItem

    /// Return the list of all model items of this type
    var modelItems: [CADTaskListItemModelType] { get }

    /// Return all items of this type based on the current filter
    func filteredItems(filterViewModel: TasksMapFilterViewModel) -> [CADTaskListItemModelType]

    /// Return all annotations of this type based on the current filter and source selection
    func filteredAnnotations(filterViewModel: TasksMapFilterViewModel, selectedSource: CADTaskListSourceType) -> [TaskAnnotation]

    /// Return the sectioned task list content for current filter and optional search text
    func sectionedListContent(filterViewModel: TasksMapFilterViewModel, searchText: String?) -> [[CADFormCollectionSectionViewModel<TasksListItemViewModel>]]

    /// The annotation view type to use for prioritising items on map
    var annotationViewType: MKAnnotationView.Type? { get }

    /// Whether items of this type can be created
    var canCreate: Bool { get }

    /// Create the view model for an item of this type with given id
    func createItemViewModel(identifier: String) -> TaskItemViewModel?
}

/// Equality check without conforming to Equatable, to prevent need for type erasure
public func ==(lhs: CADTaskListSourceType?, rhs: CADTaskListSourceType?) -> Bool {
    return lhs?.rawValue == rhs?.rawValue
}

/// Inquality check (required when not using Equatable)
public func !=(lhs: CADTaskListSourceType?, rhs: CADTaskListSourceType?) -> Bool {
    return !(lhs?.rawValue == rhs?.rawValue)
}
