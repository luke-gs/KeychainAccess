//
//  EventEntityDetailViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class EventEntityDetailViewModel {

    public unowned var event: Event
    public unowned var entity: MPOLKitEntity

    init(entity: MPOLKitEntity, event: Event) {
        self.event = event
        self.entity = entity
    }

    func viewControllers() -> [UIViewController] {
        return [
            EventEntityDescriptionViewController(),
            EventEntityRelationshipsViewController()
        ]
    }

    func headerView() -> UIView {
        let headerView = SidebarHeaderView()

        let detailDisplayable = EntityDetailsDisplayable(entity)
        headerView.captionLabel.text = detailDisplayable.entityDisplayName?.localizedUppercase

        let summaryDisplayable = EntitySummaryDisplayFormatter.default.summaryDisplayForEntity(entity)
        headerView.titleLabel.text = summaryDisplayable?.title

        if let thumbnailInfo = summaryDisplayable?.thumbnail(ofSize: .small) {
            headerView.iconView.setImage(with: thumbnailInfo)
        }
        
        return headerView
    }
}
