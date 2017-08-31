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
    
    /// The search configuration containing the frequency of typeahead search.
    var configuration: LocationSearchConfiguration { get }
    
    /// The search promise that performs the look up.
    ///
    /// - Parameters:
    ///   - text: The text entered.
    /// - Returns: The promise object
    func locationSearchPromise(text: String) -> Promise<[LookupAddress]>?
}


/// A default implementation of the search strategy that uses APIManager's type ahead search address.
open class LookupAddressLocationSearchStrategy: LocationSearchStrategy {
    public let source: EntitySource
    public let configuration: LocationSearchConfiguration
    
    public init(source: EntitySource, configuration: LocationSearchConfiguration = LocationSearchConfiguration.default) {
        self.source = source
        self.configuration = configuration
    }
    
    open func locationSearchPromise(text: String) -> Promise<[LookupAddress]>? {
        return APIManager.shared.typeAheadSearchAddress(in: source, with: LookupAddressSearchRequest(searchText: text))
    }
}
