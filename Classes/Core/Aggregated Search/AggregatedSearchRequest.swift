//
//  AggregatedSearchRequest.swift
//  MPOLKit
//
//  Created by KGWH78 on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

open class AggregatedSearchRequest<T: MPOLKitEntity> {
    public let request:     EntitySearchRequest<T>
    public let source:      EntitySource
    public let sortHandler: ((T, T) -> Bool)?
    
    public init(source: EntitySource, request: EntitySearchRequest<T>, sortHandler: ((T, T) -> Bool)? = nil) {
        self.source      = source
        self.request     = request
        self.sortHandler = nil
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
