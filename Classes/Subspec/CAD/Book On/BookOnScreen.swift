//
//  BookOnScreen.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Enum for all CAD book on screens that are presented
public enum BookOnScreen: Presentable {
    case notBookedOn
    case manageBookOn
    case callSignList
    case bookOnDetailsForm(callsignViewModel: BookOnCallsignViewModelType)
    case officerDetailsForm(officerViewModel: BookOnDetailsFormContentOfficerViewModel)
    case officerList
    case patrolAreaList
}
