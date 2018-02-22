//
//  CADTaskListSourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an enum representing a source of items in the task list
/// eg Incidents, Resources, Patrols, Broadcasts, KALOFs
public protocol CADTaskListSourceType {

    // MARK: - Static

    /// All enum cases, in order of display
    static var allCases: [CADTaskListSourceType] { get }

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

    /// The list of model items of this type
    var modelItems: [CADTaskListItemModelType] { get }

    /// Return all items of this type based on the current filter
    func filteredItems(filterViewModel: TaskMapFilterViewModel) -> [CADTaskListItemModelType]

    /// Return all annotations of this type based on the current filter and source selection
    func filteredAnnotations(filterViewModel: TaskMapFilterViewModel, selectedSource: CADTaskListSourceType) -> [TaskAnnotation]

    /// Return the source bar item of this type based on the current filter
    func sourceItem(filterViewModel: TaskMapFilterViewModel) -> SourceItem

    /// Update the content of the list based on sectioning the current filtered items
    func updateListContent(listViewModel: TasksListViewModel, filterViewModel: TaskMapFilterViewModel)

    /// The annotation view type to use for displaying items on map
    var annotationViewType: MKAnnotationView.Type? { get }

    /// Whether items of this type can be created
    var canCreate: Bool { get }
}
