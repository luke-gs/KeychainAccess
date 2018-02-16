//
//  CADClientModelTypes.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Class for handling static client specific model type overrides
/// These should be set in ClientKit or App before use!
open class CADClientModelTypes {

    /// The type used for a resource status
    static open var resourceStatus: CADResourceStatusType.Type!

    /// The type used for a resource unit type
    static open var resourceUnit: CADResourceUnitType.Type!

    /// The type used for an incident grade
    static open var incidentGrade: CADIncidentGradeType.Type!

}
