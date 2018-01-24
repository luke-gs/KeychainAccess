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

    /// Create/edit book on details screen
    case bookOnDetailsForm(callsignViewModel: BookOnCallsignViewModelType, formSheet: Bool)

    /// All callsigns list screen
    case callSignList

    /// Manage current book on landing screen
    case manageBookOn

    /// Initial screen shown when booking on
    case notBookedOn

    /// Create/edit book on officer details screen
    case officerDetailsForm(officerViewModel: BookOnDetailsFormContentOfficerViewModel, delegate: OfficerDetailsViewModelDelegate?)

    /// All officers list screen
    case officerList(detailsDelegate: OfficerDetailsViewModelDelegate?)

    /// All patrol areas list screen
    case patrolAreaList(current: String, delegate: PatrolAreaListViewModelDelegate?)

    /// Enter reason for resource status change
    case statusChangeReason(completionHandler: ((String?) -> Void)?)

    /// Create traffic stop incident
    case trafficStop(completionHandler: ((TrafficStopRequest?) -> Void)?)
    
    /// Enter finalise details
    case finaliseDetails(primaryCode: String, completionHandler: ((_ secondaryCode: String?, _ remark: String?) -> Void)?)
}
