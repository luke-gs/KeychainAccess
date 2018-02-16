//
//  DataStore.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public protocol DataStoreResult {

    associatedtype Item

    var items: [Item] { get }

}

public protocol DataStore {

    associatedtype Result: DataStoreResult

    func retrieveItems(withLastKnownResults results: Result?, cancelToken: PromiseCancellationToken?) -> Promise<Result>

    func addItem(_ item: Result.Item) -> Promise<Result.Item>

    func removeItem(_ item: Result.Item) -> Promise<Result.Item>

    func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item>

}

public enum DataStoreError: Error {

    case notSupported

}

extension DataStore {

    public func retrieveItems(withLastKnownResults results: Result?) -> Promise<Result> {
        return retrieveItems(withLastKnownResults: results, cancelToken: nil)
    }

    public func addItem(_ item: Result.Item) -> Promise<Result.Item> {
        return Promise(error: DataStoreError.notSupported)
    }

    public func removeItem(_ item: Result.Item) -> Promise<Result.Item> {
        return Promise(error: DataStoreError.notSupported)
    }

    public func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item> {
        return Promise(error: DataStoreError.notSupported)
    }

}

public protocol DataCoordinatable: class {

    associatedtype Item

    var state: DataCoordinateState { get }

    var items: [Item] { get }

    func addItem(_ item: Item) -> Promise<Item>

    func removeItem(_ item: Item) -> Promise<Item>

    func replaceItem(_ item: Item, with otherItem: Item) -> Promise<Item>

    func retrieveItems() -> Promise<[Item]>

}

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
