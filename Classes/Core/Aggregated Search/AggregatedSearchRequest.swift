//
//  AggregatedSearchRequest.swift
//  MPOLKit
//
//  Created by KGWH78 on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Defines an entity search for a source.
open class AggregatedSearchRequest<T: MPOLKitEntity> {
    
    /// The request paramters and result type.
    public let request:     EntitySearchRequest<T>
    
    /// The source.
    public let source:      EntitySource
    
    /// Closure to sort results from search.
    public let sortHandler: ((T, T) -> Bool)?
    
    /// Indicates if the search should be generated automatically (false would require user to manually generate search).
    public let isAutomatic: Bool
    
    public init(source: EntitySource, request: EntitySearchRequest<T>, sortHandler: ((T, T) -> Bool)? = nil, automatic: Bool = true) {
        self.source      = source
        self.request     = request
        self.sortHandler = sortHandler
        self.isAutomatic = automatic
    }
    
    public func search() -> Promise<[T]> {
        return searchPromise().then { [weak self] (searchResult) -> [T] in
            guard let sortHandler = self?.sortHandler else {
                return searchResult.results
            }
            
            return searchResult.results.sorted(by: sortHandler)
        }
    }
    
    open func searchPromise() -> Promise<SearchResult<T>> {
        MPLRequiresConcreteImplementation()
    }
}
