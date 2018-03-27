//
//  TasksMapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 27/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Protocol for tasks list specific map filter view model
public protocol TasksMapFilterViewModel: MapFilterViewModel {
    /// Whether to show the type specified
    func showsType(_ type: CADTaskListSourceType) -> Bool
    
    /// Whether to show results outside the patrol area
    var showResultsOutsidePatrolArea: Bool { get }
}

/// Protocol for tasks map filter that can filter incidents based on conditions
public protocol IncidentsFilterable {
    var priorities: [CADIncidentGradeType] { get }
    var resourcedIncidents: [CADIncidentStatusType] { get }
}

/// Protocol for tasks map filter that can filter resources based on conditions
public protocol ResourcesFilterable {
    var taskedResources: (tasked: Bool, untasked: Bool) { get }
}
