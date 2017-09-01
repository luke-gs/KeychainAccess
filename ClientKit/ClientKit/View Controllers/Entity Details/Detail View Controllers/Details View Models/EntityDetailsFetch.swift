//
//  EntityDetailsFetch.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public enum FetchState {
    case idle
    case fetching
    case finished
}

public struct FetchResult<T: MPOLKitEntity> {
    public var request: EntityDetailsFetchRequest<T>
    public var entity: T?
    public var state: FetchState = .idle
    public var error: Error?
}

public protocol EntityDetailsFetchDelegate: class {
    
    func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didBeginFetch request: EntityDetailsFetchRequest<T>)
    
    func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didFinishFetch request: EntityDetailsFetchRequest<T>)
}

public class EntityDetailsFetch<T: MPOLKitEntity>: Fetchable {
    
    public let requests: [EntityDetailsFetchRequest<T>]
    
    public weak var delegate: EntityDetailsFetchDelegate?
    
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
    
    public init(requests: [EntityDetailsFetchRequest<T>]) {
        self.requests = requests
    }
    
    public func performFetch() {
        guard state != .fetching else { return }
        
        for request in requests {
            fetch(for: request)
        }
    }
    
    private func fetch(for request: EntityDetailsFetchRequest<T>) {
        firstly {
            beginFetch(for: request)
            return request.fetch()
            }.then { [weak self] result in
                self?.endFetch(for: request, entity: result)
            }.catch { [weak self] in
                self?.endFetch(for: request, error: $0)
        }
    }
    
    private func beginFetch(for request: EntityDetailsFetchRequest<T>) {
        
        let result = FetchResult(request: request, entity: nil, state: .fetching, error: nil)
        
        if let index = results.index(where: { $0.request === request }) {
            results[index] = result
        } else if let index = requests.index(where: { $0 === request }), index < results.count {
            results.insert(result, at: index)
        } else {
            results.append(result)
        }
        
        delegate?.entityDetailsFetch(self, didBeginFetch: request)
    }
    
    
    private func endFetch(for request: EntityDetailsFetchRequest<T>, entity: T) {
        
        guard let index = results.index(where: { $0.request === request }) else { return }
        
        let result = FetchResult(request: request, entity: entity, state: .finished, error: nil)
        results[index] = result
        
        delegate?.entityDetailsFetch(self, didFinishFetch: request)
    }
    
    private func endFetch(for request: EntityDetailsFetchRequest<T>, error: Error) {
        guard let index = results.index(where: { $0.request === request }) else { return }
        
        let result = FetchResult(request: request, entity: nil, state: .finished, error: error)
        results[index] = result
        
        delegate?.entityDetailsFetch(self, didFinishFetch: request)
    }
}
