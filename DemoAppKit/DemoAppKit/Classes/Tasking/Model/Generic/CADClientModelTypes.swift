//
//  CADClientModelTypes.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Class for handling client specific model type overrides
///
/// NOTE: These should be set in ClientKit or App before use!!
///
open class CADClientModelTypes {

    // MARK: - Requests, so they can be created polymorphically in mpolkit using client kit versions

    /// The type used for officer details
    static public var officerDetails: CADOfficerType.Type!

    /// The type used for officer details
    static public var equipmentDetails: CADEquipmentType.Type!

    // MARK: - Enums

    /// The type used for task list sources
    static public var taskListSources: CADTaskListSourceType.Type!

    /// The type used for a resource status
    static public var resourceStatus: CADResourceStatusType.Type!

    /// The type used for a resource unit type
    static public var resourceUnit: CADResourceUnitType.Type!

    /// The type used for an incident grade
    static public var incidentGrade: CADIncidentGradeType.Type!

    /// The type used for an incident grade
    static public var incidentStatus: CADIncidentStatusType.Type!

    /// The type used for a broadcast category
    static public var broadcastCategory: CADBroadcastCategoryType.Type!

    /// The type used for a patrol status
    static public var patrolStatus: CADPatrolStatusType.Type!

    /// The type used for association alert levels
    static public var alertLevel: CADAlertLevelType.Type!

}
