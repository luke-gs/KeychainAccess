//
//  CADClientModelTypes.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Class for handling client specific model type overrides of static enums
/// These should be set in ClientKit or App before use!
open class CADClientModelTypes {

    // MARK: - Requests

    /// The type used for a book on details
    static open var bookonDetails: CADBookOnDetailsType.Type!

    /// The type used for officer details
    static open var officerDetails: CADOfficerType.Type!

    /// The type used for officer details
    static open var equipmentDetails: CADEquipmentType.Type!

    // MARK: - Enums

    /// The type used for a resource status
    static open var resourceStatus: CADResourceStatusType.Type!

    /// The type used for a resource unit type
    static open var resourceUnit: CADResourceUnitType.Type!

    /// The type used for an incident grade
    static open var incidentGrade: CADIncidentGradeType.Type!

    /// The type used for an incident grade
    static open var incidentStatus: CADIncidentStatusType.Type!

    /// The type used for a broadcast category
    static open var broadcastCategory: CADBroadcastCategoryType.Type!

    /// The type used for a patrol status
    static open var patrolStatus: CADPatrolStatusType.Type!

}
