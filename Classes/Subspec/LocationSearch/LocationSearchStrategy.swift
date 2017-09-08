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

    /// The result model type that should be created.
    var resultModelType: MapResultViewModelable.Type { get }

    /// The search configuration containing the frequency of typeahead search.
    var configuration: LocationSearchConfiguration { get }
    
    /// The search promise that performs the look up.
    ///
    /// - Parameters:
    ///   - text: The text entered.
    /// - Returns: The promise object
    func locationTypeaheadPromise(text: String) -> Promise<[Location]>?
}


