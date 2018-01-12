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

    public var entityDelegate: EntityDetailsDelegate?

    var recentViewModel: SearchRecentsViewModel = MPOLSearchRecentsViewModel()

    let dataSources: [SearchDataSource]

    init() {

        let strategy = LookupAddressLocationSearchStrategy<Address, AddressSummaryDisplayable>(source: MPOLSource.gnaf, helpPresentable: EntityScreen.help(type: .location))
        let locationDataSource = LocationSearchDataSource(strategy: strategy, advanceOptions: LookupAddressLocationAdvancedOptions())
        strategy.onResultModelForMap = {
            return LocationMapSummarySearchResultViewModel()
        }
        strategy.onResultModelForResult = { (lookupResult, searchable) in
            return LocationMapSummarySearchResultViewModel()
//            let preferredViewModel = MapSummarySearchResultViewModel<T, U>()
//            preferredViewModel.fetchResults(withCoordinate: result.location.coordinate)
//            return preferredViewModel

        }
/*
         public var onResultModelForResult: ((LookupResult, Searchable) -> SearchResultModelable)? = { (result, searchable) in
         let preferredViewModel = MapSummarySearchResultViewModel<T, U>()
         preferredViewModel.fetchResults(withCoordinate: result.location.coordinate)
         return preferredViewModel
         }
 */
        self.dataSources = [
            PersonSearchDataSource(),
            VehicleSearchDataSource(),
            locationDataSource
        ]
    }

    func presentable(for entity: MPOLKitEntity) -> Presentable {
        return EntityScreen.entityDetails(entity: entity as! Entity, delegate: entityDelegate)
    }

}

class MPOLSearchRecentsViewModel: SearchRecentsViewModel {

    var title: String = "MPOL"

    var recentlyViewed: EntityBucket { return UserSession.current.recentlyViewed }

    var recentlySearched: [Searchable] {
        get {
            return UserSession.current.recentlySearched
        }

        set {
            UserSession.current.recentlySearched = newValue
        }
    }

    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath) {
        let entities = recentlyViewed.entities
        let entity = entities[indexPath.item]

        cell.style = .detail

        switch entity {
        case entity as Person:
            cell.decorate(with: PersonSummaryDisplayable(entity))
        case entity as Vehicle:
            cell.decorate(with: VehicleSummaryDisplayable(entity))
        default:
            break
        }
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
