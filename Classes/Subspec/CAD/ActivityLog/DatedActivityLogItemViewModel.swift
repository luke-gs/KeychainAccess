//
//  DatedActivityLogItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public struct DatedActivityLogItemViewModel {
    public let date: Date
    public let activityLogViewModel: ActivityLogViewModel
    
    public init(date: Date, activityLogViewModel: ActivityLogViewModel) {
        self.date = date
        self.activityLogViewModel = activityLogViewModel
    }
}
