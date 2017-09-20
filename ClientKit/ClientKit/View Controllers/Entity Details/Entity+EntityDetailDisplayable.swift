//
//  Entity+EntityDetailDisplayable.swift
//  ClientKit
//
//  Created by Bryan Hathaway on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension Entity: EntityDetailDisplayable {

    public var entityDisplayName: String? {
        return type(of: self).localizedDisplayName
    }

    public var alertBadgeCount: UInt? {
        return actionCount
    }

    public var alertBadgeColor: UIColor? {
        return alertLevel?.color
    }

    public var lastUpdatedString: String? {
        guard let lastUpdated = self.lastUpdated else { return nil }
        let lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
        return lastUpdatedString
    }


}
