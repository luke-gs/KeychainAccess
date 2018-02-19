//
//  LocalStore.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public struct LocalDataResults<T: Equatable>: DataStoreResult, Equatable {

    public let items: [T]

    public init(items: [T]) {
        self.items = items
    }

    public static func ==(lhs: LocalDataResults, rhs: LocalDataResults) -> Bool {
        return lhs.items == rhs.items
    }

}


public enum LocalDataStoreError: LocalizedError {
    case duplicate
    case notFound
    case notSupported

    public var errorDescription: String? {
        switch self {
        case .duplicate: return "Duplicate found."
        case .notFound:  return "Not found."
        case .notSupported: return "Not supported"
        }
    }
}

public class LocalDataStore<T>: WritableDataStore, ExpressibleByArrayLiteral where T: Equatable {

    public typealias Result = LocalDataResults<T>

    public private(set) var items: [T]

    public init(items: [T]) {
        self.items = items
    }

    public required init(arrayLiteral elements: T...) {
        self.items = elements
    }

    public func retrieveItems(withLastKnownResults results: Result?, cancelToken: PromiseCancellationToken?) -> Promise<Result> {
        return Promise(value: LocalDataResults(items: items))
    }

    public func addItem(_ item: Result.Item) -> Promise<Result.Item> {
        return Promise { [unowned self] fullfill, reject in
            if self.indexOfItem(item) == nil {
                self.items.append(item)
                fullfill(item)
            } else {
                reject(LocalDataStoreError.duplicate)
            }
        }
    }

    public func removeItem(_ item: Result.Item) -> Promise<Result.Item> {
        return Promise { [unowned self] fullfill, reject in
            if let index = self.indexOfItem(item) {
                self.items.remove(at: index)
                fullfill(item)
            } else {
                reject(LocalDataStoreError.notFound)
            }
        }
    }

    public func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item> {
        return Promise { [unowned self] fullfill, reject in
            guard let index = self.indexOfItem(item) else {
                reject(LocalDataStoreError.notFound)
                return
            }

            guard self.indexOfItem(otherItem) == nil else {
                reject(LocalDataStoreError.duplicate)
                return
            }

            var items = self.items
            items.remove(at: index)
            items.insert(otherItem, at: index)

            self.items = items
            fullfill(otherItem)
        }
    }

    private func indexOfItem(_ item: Result.Item) -> Int? {
        return items.index(where: { $0 == item })
    }

}
