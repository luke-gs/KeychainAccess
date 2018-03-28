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
