//
//  SyncDetailsActivityLogItem+Computed.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension SyncDetailsActivityLogItem {
    
    open var color: UIColor {
        if source == "Dispatch" {
            return .disabledGray
        } else {
            return .primaryGray
        }
    }
    
    /// Timestamp string
    open var timestampString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: timestamp)
    }
}
