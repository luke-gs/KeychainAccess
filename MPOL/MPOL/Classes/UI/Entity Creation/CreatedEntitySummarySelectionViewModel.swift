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

    public static let createdEntitiesKey = "createdEntitiesKey"
    public static let didUpdateNotificationName = Notification.Name(rawValue: "CreatedEntityDidUpdateNotification")

    public override init() {
        super.init()
        // Load initial entities
        reloadEntities()

        // Refresh list whenever created viewed entities change
        NotificationCenter.default.addObserver(self, selector: #selector(handleCreatedViewedChanged), name: CreatedEntitySummarySelectionSectionViewModel.didUpdateNotificationName, object: nil)
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
        let item: [Person]? = UserSession.current.userStorage?.retrieve(key: CreatedEntitySummarySelectionSectionViewModel.createdEntitiesKey) ?? nil
        // Update entities and trigger UI update
        if let item = item {
            updateEntityList(item)
        }
    }
}
