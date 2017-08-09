//
//  AggregatedSearch.swift
//  MPOLKit
//
//  Created by KGWH78 on 4/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public enum SearchState {
    case idle
    case searching
    case finished
}


public struct AggregatedResult<T: MPOLKitEntity> {
    public var request:    AggregatedSearchRequest<T>
    public var entities:   [T]
    public var state:      SearchState = .idle
    public var error:      Error? = nil
}


public protocol AggregatedSearchDelegate: class {
    func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didBeginSearch request: AggregatedSearchRequest<U>)
    func aggregatedSearch<U>(_ aggregatedSearch: AggregatedSearch<U>, didEndSearch request: AggregatedSearchRequest<U>)
}


public class AggregatedSearch<T: MPOLKitEntity> {
    
    public let requests: [AggregatedSearchRequest<T>]
    
    public weak var delegate: AggregatedSearchDelegate?
    
    public private(set) var results: [AggregatedResult<T>] = []
    
    public var state: SearchState {
        if results.count == 0 {
            return .idle
        } else if let _ = results.first(where: { $0.state == .searching }) {
            return .searching
        } else {
            return .finished
        }
    }
    
    public var totalEntitiesFound: Int {
        return results.reduce(0, { (total, result) -> Int in
            total + result.entities.count
        })
    }
    
    public init(requests: [AggregatedSearchRequest<T>]) {
        self.requests = requests
    }
    
    // MARK: - Actions
    
    public func performSearch() {
        guard state != .searching else { return }
        
        for request in requests {
            retrySearch(request: request)
        }
    }
    
    public func retrySearchForResult(result: AggregatedResult<T>) {
        guard result.state != .searching else { return }
        retrySearch(request: result.request)
    }
    
    // MARK: - Private
    
    private func retrySearch(request: AggregatedSearchRequest<T>) {
        firstly {
            beginSearch(for: request)
            return request.search()
        }.then { [weak self] results in
            self?.endSearch(for: request, entities: results)
        }.catch { [weak self] in
            self?.endSearch(for: request, error: $0)
        }
    }
    
    private func beginSearch(for request: AggregatedSearchRequest<T>) {
        let aggregatedResult = AggregatedResult(request: request,
                                                entities: [],
                                                state: .searching,
                                                error: nil)
        
        
        if let index = results.index(where: { $0.request === request }) {
            results[index] = aggregatedResult
        } else if let index = requests.index(where: { $0 === request }), index < results.count {
            results.insert(aggregatedResult, at: index)
        } else {
            results.append(aggregatedResult)
        }
        
        delegate?.aggregatedSearch(self, didBeginSearch: request)
    }
    
    
    private func endSearch(for request: AggregatedSearchRequest<T>, entities: [T]) {
        guard let index = results.index(where: { $0.request === request }) else {
            return
        }
        
        results[index] = AggregatedResult(request: request,
                                          entities: entities,
                                          state: .finished,
                                          error: nil)
        
        delegate?.aggregatedSearch(self, didEndSearch: request)
    }
    
    private func endSearch(for request: AggregatedSearchRequest<T>, error: Error) {
        guard let index = results.index(where: { $0.request === request }) else {
            return
        }
        
        results[index] = AggregatedResult(request: request,
                                          entities: [],
                                          state: .finished,
                                          error: error)
        
        delegate?.aggregatedSearch(self, didEndSearch: request)
    }
    
}


