//
//  Reportable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// A convenience for objects that will want to conform to both
/// an eventReportable as well as incidentReportable
public protocol Reportable: IncidentReportable, EventReportable { }

