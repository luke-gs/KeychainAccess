//
//  CreatedEntitySummarySelectionViewModel.swift
//  PublicSafetyKit
//
//  Created by Evan Tsai on 1/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class CreatedEntitySummarySelectionViewModel: EntitySummarySelectionViewModel {

    public static let createdEntitiesKey = "createdEntitiesKey"

    public override init() {
        super.init()
        // Load initial entities
        reloadEntities()
    }

    open override var sectionTitle: String? {
        return AssetManager.shared.string(forKey: .createdViewedEntitySelectionTitle)
    }

    open override var noContentTitle: String? {
        return AssetManager.shared.string(forKey: .createdViewedEntitySelectionNoContentTitle)
    }

    open func reloadEntities() {
        // Use the created entities as data source
        let item: [Person]? = UserSession.current.userStorage?.retrieve(key: CreatedEntitySummarySelectionViewModel.createdEntitiesKey) ?? nil
        // Update entities and trigger UI update
        if let item = item {
            updateEntityList(item)
        }
    }
}
