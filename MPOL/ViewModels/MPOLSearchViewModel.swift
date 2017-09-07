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

    var dataSources: [SearchDataSource] = [
        PersonSearchDataSource(),
        VehicleSearchDataSource(),
        LocationSearchDataSource(strategy: LookupAddressLocationSearchStrategy(source: MPOLSource.gnaf,
                                                                               resultModelType: MapSummarySearchResultViewModel.self),
                                                                               advanceOptions: LookupAddressLocationAdvancedOptions())
    ]

    func presentable(for entity: MPOLKitEntity) -> Presentable {
        return AppScreen.entityDetails(entity: entity as! Entity)
    }

}

class MPOLSearchRecentsViewModel: SearchRecentsViewModel {

    var title: String = "MPOL"

    var recentlyViewed: [MPOLKitEntity] = []

    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) {
        let entity = recentlyViewed[indexPath.item]

        cell.style = .detail
        cell.decorate(with: entity as! EntitySummaryDisplayable)
    }

    func summaryIcon(for searchable: Searchable) -> UIImage? {
        guard let type = searchable.type else { return nil }

        switch type {
        case PersonSearchDataSource.searchableType:
            return AssetManager.shared.image(forKey: .entityPerson)
        case VehicleSearchDataSource.searchableType:
            return AssetManager.shared.image(forKey: .entityCar)
        case LocationSearchDataSourceSearchableType:
            return AssetManager.shared.image(forKey: .location)
        default:
            return AssetManager.shared.image(forKey: .info)
        }
    }

}
