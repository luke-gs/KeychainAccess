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

public let DataStoreCoordinatorDidChangeStateNotification = Notification.Name(rawValue: "DataStoreCoordinatorDidChangeStateNotificationName")

public class DataStoreCoordinator<Store: ReadableDataStore> where Store.Result.Item: Equatable {

    public typealias Item = Store.Result.Item

    public private(set) var state: DataCoordinateState = .unknown {
        didSet {
            NotificationCenter.default.post(name: DataStoreCoordinatorDidChangeStateNotification, object: self)
        }
    }

    public private(set) var items: [Item] = []

    public let dataStore: Store

    // MARK: - Internal states

    private enum Priority {
        case high
        case low
    }

    private var lastKnownResults: Store.Result?

    private var activeRequest: (promise: Promise<[Item]>, cancelToken: PromiseCancellationToken, priority: Priority)?

    // MARK: - Initializer

    public init(dataStore: Store) {
        self.dataStore = dataStore
    }

    deinit {
        activeRequest?.cancelToken.cancel()
    }

    public func retrieveItems() -> Promise<[Item]> {
        if let activeRequest = activeRequest {
            if activeRequest.priority == .high {
                return activeRequest.promise
            }

            activeRequest.cancelToken.cancel()
            self.activeRequest = nil
        }

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
            self.activeRequest = nil
        }

        self.activeRequest = (retrievePromise, cancelToken, .high)

        return retrievePromise
    }

}



extension DataStoreCoordinator where Store.Result: PaginatedDataStoreResult {

    public func hasMoreItems() -> Bool {
        return lastKnownResults?.hasMoreItems ?? false
    }

    public func retrieveMoreItems() -> Promise<[Item]> {
        if lastKnownResults == nil {
            return retrieveItems()
        }

        if let activeRequest = activeRequest {
            return activeRequest.promise
        }

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
            self.activeRequest = nil
        }

        self.activeRequest = (retrievePromise, cancelToken, .low)

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
