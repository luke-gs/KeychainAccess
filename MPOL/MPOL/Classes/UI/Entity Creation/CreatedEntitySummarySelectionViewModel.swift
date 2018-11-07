//
//  CreatedEntitySummarySelectionViewModel.swift
//
//  Created by Evan Tsai on 1/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// View Model for showing created section in Entity Summary Selection
open class CreatedEntitySummarySelectionSectionViewModel: EntitySummarySelectionSectionViewModel {

    public override init() {
        super.init()
        // Load initial entities
        reloadEntities()

        // Refresh list whenever created viewed entities change
        NotificationCenter.default.addObserver(self, selector: #selector(handleCreatedViewedChanged), name: NSNotification.Name.CreatedEntitiesDidUpdate, object: nil)
    }

    open override var title: String? {
        return AssetManager.shared.string(forKey: .createdEntitySelectionTitle)
    }

    @objc open func handleCreatedViewedChanged() {
        // Update entities, and therefore summaries when recently viewed entities changes
        reloadEntities()
    }

    open func reloadEntities() {
        // Use the created entities as data source
        let item: [MPOLKitEntity]? = UserSession.current.userStorage?.getEntities(key: UserStorage.CreatedEntitiesKey)
        // Update entities and trigger UI update
        if let item = item {
            updateEntityList(item)
        }
    }
}
