//
//  LocationSearchStrategy.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Defines a search strategy for location search data source.
public protocol LocationSearchStrategy {
    
    associatedtype Location: Locatable

    /// The search configuration containing the frequency of typeahead search.
    var configuration: LocationSearchConfiguration { get }

    /// The help presentable
    var helpPresentable: Presentable { get }

    /// The search promise that performs the look up.
    ///
    /// - Parameters:
    ///   - text: The text entered.
    /// - Returns: The promise object
    func locationTypeaheadPromise(text: String) -> Promise<[Location]>?

    /// The map result view model for map action.
    /// If nil, the map option will not be displayed.
    ///
    /// - Returns: The map view model
    func resultModelForMap() -> MapResultViewModelable?

    /// The view model for selecting a look up result
    ///
    /// - Parameter result: The lookup result
    /// - Returns: The view model
    func resultModelForSearchOnLocation(withResult result: LookupResult) -> SearchResultModelable?

    /// The map result view model for a set of parameters
    ///
    /// - Parameter parameters: The parameters from advanced search
    /// - Returns: The view model
    func resultModelForSearchOnLocation(withParameters parameters: Parameterisable) -> SearchResultModelable?

}
