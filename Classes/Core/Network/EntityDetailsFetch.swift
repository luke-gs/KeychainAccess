//
//  EntityDetailFetch.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public enum FetchState {
    case idle
    case fetching
    case finished
}

public struct FetchResult<T: MPOLKitEntity> {
    public var request: EntityDetailFetchRequest<T>
    public var entity: T?
    public var state: FetchState = .idle
    public var error: Error?
}

public protocol EntityDetailFetchDelegate: class {
    
    func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didBeginFetch request: EntityDetailFetchRequest<T>)
    
    func EntityDetailFetch<T>(_ EntityDetailFetch: EntityDetailFetch<T>, didFinishFetch request: EntityDetailFetchRequest<T>)
}

public class EntityDetailFetch<T: MPOLKitEntity>: Fetchable {
    
    public let requests: [EntityDetailFetchRequest<T>]
    
    public weak var delegate: EntityDetailFetchDelegate?
    
    public private(set) var results: [FetchResult<T>] = []
    
    public var state: FetchState {
        if results.count == 0 {
            return .idle
        } else if let _ = results.first(where: { $0.state == .fetching }) {
            return .fetching
        } else {
            return .finished
        }
    }

    public init(requests: [EntityDetailFetchRequest<T>]) {
        self.requests = requests
    }

    public init(request: EntityDetailFetchRequest<T>) {
        self.requests = [request]
    }

    public func performFetch() {
        guard state != .fetching else { return }
        
        for request in requests {
            fetch(for: request)
        }
    }
    
    private func fetch(for request: EntityDetailFetchRequest<T>) {
        firstly {
            beginFetch(for: request)
            return request.fetch()
            }.then { [weak self] result in
                self?.endFetch(for: request, entity: result)
            }.catch { [weak self] in
                self?.endFetch(for: request, error: $0)
        }
    }
    
    private func beginFetch(for request: EntityDetailFetchRequest<T>) {
        
        let result = FetchResult(request: request, entity: nil, state: .fetching, error: nil)
        
        if let index = results.index(where: { $0.request === request }) {
            results[index] = result
        } else if let index = requests.index(where: { $0 === request }), index < results.count {
            results.insert(result, at: index)
        } else {
            results.append(result)
        }
        
        delegate?.EntityDetailFetch(self, didBeginFetch: request)
    }
    
    
    private func endFetch(for request: EntityDetailFetchRequest<T>, entity: T) {
        
        guard let index = results.index(where: { $0.request === request }) else { return }
        
        let result = FetchResult(request: request, entity: entity, state: .finished, error: nil)
        results[index] = result
        
        delegate?.EntityDetailFetch(self, didFinishFetch: request)
    }
    
    private func endFetch(for request: EntityDetailFetchRequest<T>, error: Error) {
        guard let index = results.index(where: { $0.request === request }) else { return }
        
        let result = FetchResult(request: request, entity: nil, state: .finished, error: error)
        results[index] = result
        
        delegate?.EntityDetailFetch(self, didFinishFetch: request)
    }
}
