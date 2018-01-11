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

    // All patrol areas list screen
    case patrolAreaList(current: String, delegate: PatrolAreaListViewModelDelegate?)

    // All callsigns list screen
    case callSignList

    // All officers list screen
    case officerList(detailsDelegate: OfficerDetailsViewModelDelegate?)

    // Initial screen shown when booking on
    case notBookedOn

    // Manage current book on landing screen
    case manageBookOn

    // Create/edit book on details screen
    case bookOnDetailsForm(callsignViewModel: BookOnCallsignViewModelType)

    // Create/edit book on officer details screen
    case officerDetailsForm(officerViewModel: BookOnDetailsFormContentOfficerViewModel, delegate: OfficerDetailsViewModelDelegate?)

}
