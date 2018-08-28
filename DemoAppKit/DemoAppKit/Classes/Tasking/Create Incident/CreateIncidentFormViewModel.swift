//
//  CreateIncidentFormViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for incident details entered in create incident form
open class CreateIncidentFormViewModel {
    open var status: CADResourceStatusType?
    open var priority: CADIncidentGradeType?
    open var primaryCode: String?
    open var secondaryCode: String?
    open var location: String? // TODO: Use CADLocationType?
    open var description: String?
    open var informantName: String?
    open var informantPhone: String?
}
