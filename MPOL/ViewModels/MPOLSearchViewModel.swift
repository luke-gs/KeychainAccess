//
//  MPOLSearchViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 19/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

class MPOLSearchViewModel: SearchViewModel {
    var recentViewModel: SearchRecentsViewModel = MPOLSearchRecentsViewModel()
    var dataSources: [SearchDataSource] = [PersonSearchDataSource(), VehicleSearchDataSource()]
}

class MPOLSearchRecentsViewModel: SearchRecentsViewModel {

    var title: String = "MPOL"

    var recentlyViewed: [MPOLKitEntity] {
        get {
            return internalRecentlyViewed
        }

        set {
            guard let entities = newValue as? [Entity] else { return }
            internalRecentlyViewed = entities
        }
    }

    private var internalRecentlyViewed: [Entity] = []

    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) {
        let person = internalRecentlyViewed[indexPath.item]

        cell.style              = .detail
        cell.highlightStyle     = .fade
        cell.titleLabel.text    = person.summary
        cell.subtitleLabel.text = person.summaryDetail1
        cell.detailLabel.text   = person.summaryDetail2
        cell.thumbnailView.configure(for: person, size: .medium)
        cell.sourceLabel.text   = person.source?.localizedBadgeTitle
        cell.badgeCount         = person.actionCount
        cell.alertColor         = person.alertLevel?.color
    }

    func summaryIcon(for searchable: Searchable) -> UIImage? {
        guard let type = searchable.type else { return nil }

        //Could probably enum this out as well
        switch type {
        case "Person":
            return AssetManager.shared.image(forKey: .entityPerson)
        case "Vehicle":
            return AssetManager.shared.image(forKey: .entityCar)
        default:
            return AssetManager.shared.image(forKey: .entityPerson)
        }
    }
}
