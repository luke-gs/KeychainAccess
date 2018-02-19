//
//  SyncDetailsInformant.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for an informant in an incident
open class SyncDetailsIncidentInformant: Codable, CADIncidentInformantType {
    open var fullName : String!
    open var primaryPhone : String!
    open var secondaryPhone : String!
}
