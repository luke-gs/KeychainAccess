//
//  DataCoordinator.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit


public enum DataCoordinateState {
    case unknown
    case loading
    case completed
    case error(Error)
}

extension DataCoordinateState: Equatable {

    public static func ==(lhs: DataCoordinateState, rhs: DataCoordinateState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case (.loading, .loading): return true
        case (.completed, .completed): return true
        case (.error(let error1), .error(let error2)): return (error1 as NSError) == (error2 as NSError)
        default: return false
        }
    }

}

public protocol PaginatedDataStoreResult: DataStoreResult {

    var hasMoreItems: Bool { get }

}

public let DataStoreCoordinatorDidChangeStateNotificationName = Notification.Name(rawValue: "DataStoreCoordinatorDidChangeStateNotificationName")

public class DataStoreCoordinator<Store: ReadableDataStore> where Store.Result.Item: Equatable {

    public typealias Item = Store.Result.Item

    public private(set) var state: DataCoordinateState = .unknown {
        didSet {
            NotificationCenter.default.post(name: DataStoreCoordinatorDidChangeStateNotificationName, object: self)
        }
    }

    public private(set) var items: [Item] = []

    public let dataStore: Store

    // MARK: - Internal states

    private var lastKnownResults: Store.Result?

    private var activePromise: (Promise<[Item]>, PromiseCancellationToken?)?

    // MARK: - Initializer

    public init(dataStore: Store) {
        self.dataStore = dataStore
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


            self?.lastKnownResults = results
            self?.items = items
            self?.state = .completed

            return self?.items ?? []
        }.always {
            self.activePromise = nil
        }

        self.activePromise = (retrievePromise, cancelToken)

        return retrievePromise
    }

}

extension DataStoreCoordinator where Store.Result: PaginatedDataStoreResult {

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

            self?.lastKnownResults = results
            self?.items += items
            self?.state = .completed

            return self?.items ?? []
        }.always {
            self.activePromise = nil
        }

        self.activePromise = (retrievePromise, cancelToken)

        return retrievePromise
    }

}

extension DataStoreCoordinator where Store: WritableDataStore {

    public func addItem(_ item: Item) -> Promise<Item> {
        return dataStore.addItem(item)
    }

    public func removeItem(_ item: Item) -> Promise<Item> {
        return dataStore.removeItem(item)
    }

    public func replaceItem(_ item: Item, with otherItem: Item) -> Promise<Item> {
        return dataStore.replaceItem(item, with: otherItem)
    }

}
