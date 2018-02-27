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

    func addItems(_ items: [Result.Item]) -> Promise<[Result.Item]>

    func removeItems(_ items: [Result.Item]) -> Promise<[Result.Item]>

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

extension WritableDataStore {

    public func addItem(_ item: Result.Item) -> Promise<Result.Item> {
        return self.addItems([item]).then { $0.first! }
    }

    public func removeItem(_ item: Result.Item) -> Promise<Result.Item> {
        return self.removeItems([item]).then { $0.first! }
    }


}
