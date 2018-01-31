//
//  LocationSearchStrategy.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


public protocol Locatable {
    var textRepresentation: String { get }
    var coordinate: CLLocationCoordinate2D { get }
}

/// Defines a typeahead strategy for location search data source.
public protocol LocationTypeaheadStrategy {

    associatedtype Location: Locatable

    /// The search configuration containing the frequency of typeahead search.
    var typeaheadConfiguration: LocationTypeaheadConfiguration { get }

    /// The search promise that performs the look up.
    ///
    /// - Parameters:
    ///   - text: The text entered.
    /// - Returns: The promise object
    func locationTypeaheadPromise(text: String) -> Promise<[Location]>?

}

public protocol LocationSearchModelStrategy {

    /// The map result view model for map action.
    /// If nil, the map option will not be displayed.
    ///
    /// - Returns: The map view model
    func resultModelForMap(attemptToSearchAtUserLocation: Bool) -> MapResultViewModelable?

    /// The view model for selecting a look up result
    ///
    /// - Parameter result: The lookup result
    ///             searchable: The searchable
    /// - Returns: The view model
    func resultModelForSearchOnLocation(withResult result: LookupResult, andSearchable searchable: Searchable) -> SearchResultModelable?

    /// The map result view model for a set of parameters
    ///
    /// - Parameter parameters: The parameters from advanced search
    ///             searchable: The searchable
    /// - Returns: The view model
    func resultModelForSearchOnLocation(withParameters parameters: Parameterisable, andSearchable searchable: Searchable) -> SearchResultModelable?


    /// The view model for a specific search type
    ///
    /// - Parameter searchType: The search type
    /// - Returns: The view model
    func resultModelForSearchOnLocation(withSearchType searchType: LocationMapSearchType) -> MapResultViewModelable?

}

public protocol LocationInteractionStrategy {

    /// The configuration containing radius information.
    var radiusConfiguration: LocationTypeRadiusConfiguration { get }

}


/// Defines a search strategy for location search data source.
public protocol LocationSearchStrategy: LocationTypeaheadStrategy, LocationSearchModelStrategy, LocationInteractionStrategy {

    /// The help presentable
    var helpPresentable: Presentable { get }

}
