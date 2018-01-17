//
//  Entity+EntityDetailDisplayable.swift
//  ClientKit
//
//  Created by Bryan Hathaway on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public struct EntityDetailsDisplayable: EntityDetailDisplayable {

    private var entity: Entity

    public init(_ entity: MPOLKitEntity) {
        self.entity = entity as! Entity
    }

    public var entityDisplayName: String? {
        return type(of: entity).localizedDisplayName
    }

    public var alertBadgeCount: UInt? {
        return entity.actionCount
    }

    public var alertBadgeColor: UIColor? {
        return entity.alertLevel?.color
    }

    public var lastUpdatedString: String? {
        guard let lastUpdated = entity.lastUpdated else { return nil }
        let lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
        return lastUpdatedString
    }


}
