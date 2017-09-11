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

    public var entityDelegate: SearchResultsEntityDelegate?

    var recentViewModel: SearchRecentsViewModel = MPOLSearchRecentsViewModel()
    var dataSources: [SearchDataSource] = [
        PersonSearchDataSource(),
        VehicleSearchDataSource(),
        LocationSearchDataSource(strategy: LookupAddressLocationSearchStrategy(source: MPOLSource.gnaf,
                                                                               resultModelType: MapSummarySearchResultViewModel.self),
                                                                               advanceOptions: LookupAddressLocationAdvancedOptions())
    ]

    func detailViewController(for entity: MPOLKitEntity) -> UIViewController? {
        var dataSource: EntityDetailSectionsDataSource?

        if entity is Person {
            dataSource = PersonDetailsSectionsDataSource(baseEntity: entity as! Entity, delegate: entityDelegate)

        } else if entity is Vehicle {
            dataSource = VehicleDetailsSectionsDataSource(baseEntity: entity as! Entity, delegate: entityDelegate)

        }

        guard dataSource != nil else { return nil }
        return EntityDetailSplitViewController(dataSource: dataSource!)

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
