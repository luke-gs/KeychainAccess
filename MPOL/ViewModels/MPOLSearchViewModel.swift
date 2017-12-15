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

    var recentViewModel: SearchRecentsViewModel = EntitySummaryRecentsViewModel(title: "MPOL")

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
