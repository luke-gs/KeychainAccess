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

public protocol ReadableDataStore {

    associatedtype Result: DataStoreResult

    func retrieveItems(withLastKnownResults results: Result?, cancelToken: PromiseCancellationToken?) -> Promise<Result>

}

public protocol WritableDataStore: ReadableDataStore {

    func addItem(_ item: Result.Item) -> Promise<Result.Item>

    func removeItem(_ item: Result.Item) -> Promise<Result.Item>

    func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item>

}

public enum DataStoreError: Error {

    case notSupported

}

extension ReadableDataStore {

    public func retrieveItems(withLastKnownResults results: Result? = nil) -> Promise<Result> {
        return retrieveItems(withLastKnownResults: results, cancelToken: nil)
    }

}
