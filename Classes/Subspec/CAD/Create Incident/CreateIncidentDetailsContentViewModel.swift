//
//  CreateIncidentDetailsContentViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for incident details entered in create incident form
open class CreateIncidentDetailsContentViewModel {
    open var status: ResourceStatus?
    open var priority: IncidentGrade?
    open var primaryCode: String?
    open var secondaryCode: String?
    open var location: String? // TODO: Use SyncDetailsLocation?
    open var description: String?
    open var informantName: String?
    open var informantPhone: String?
}
