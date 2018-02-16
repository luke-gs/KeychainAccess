//
//  DataCoordinator.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


public protocol PaginatedDataStoreResult: DataStoreResult {

    var hasMoreItems: Bool { get }

}


public class DataCoordinator<Store: DataStore>: DataCoordinatable where Store.Result.Item: Equatable {

    public typealias Item = Store.Result.Item

    public private(set) var state: DataCoordinateState = .unknown

    public private(set) var items: [Item] = []

    public let dataStore: Store

    // MARK: - Internal states

    private var lastKnownResults: Store.Result?

    private var activePromise: (Promise<[Item]>, PromiseCancellationToken?)?

    // MARK: - Initializer

    public init(dataStore: Store) {
        self.dataStore = dataStore
    }

    // MARK: - CRUD methods

    public func addItem(_ item: Item) -> Promise<Item> {
        return dataStore.addItem(item)
    }

    public func removeItem(_ item: Item) -> Promise<Item> {
        return dataStore.removeItem(item)
    }

    public func replaceItem(_ item: Item, with otherItem: Item) -> Promise<Item> {
        return dataStore.replaceItem(item, with: otherItem)
    }

    public func retrieveItems() -> Promise<[Item]> {
        lastKnownResults = nil

        state = .loading
        let cancelToken = PromiseCancellationToken()
        let retrievePromise = dataStore.retrieveItems(withLastKnownResults: nil, cancelToken: cancelToken).recover { [weak self] error -> Promise<Store.Result> in
            self?.state = .error(error)
            return Promise(error: error)
        }.then { [weak self] results -> [Item] in
            let items = results.items

            self?.state = .completed
            self?.lastKnownResults = results
            self?.items = items

            return self?.items ?? []
        }.always {
            self.activePromise = nil
        }

        self.activePromise = (retrievePromise, cancelToken)

        return retrievePromise
    }

}

extension DataCoordinator where Store.Result: PaginatedDataStoreResult {

    public func hasMoreItems() -> Bool {
        return lastKnownResults?.hasMoreItems ?? false
    }

    public func retrieveMoreItems() -> Promise<[Item]> {
        state = .loading

        let cancelToken = PromiseCancellationToken()
        let retrievePromise = dataStore.retrieveItems(withLastKnownResults: lastKnownResults, cancelToken: cancelToken).recover { [weak self] error -> Promise<Store.Result> in
            self?.state = .error(error)
            return Promise(error: error)
        }.then { [weak self] results -> [Item] in
            let items = results.items

            self?.state = .completed
            self?.lastKnownResults = results
            self?.items += items

            return self?.items ?? []
        }.always {
            self.activePromise = nil
        }

        self.activePromise = (retrievePromise, cancelToken)

        return retrievePromise
    }

}

