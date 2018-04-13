//
//  LocalStore.swift
//  MPOLKit
//
//  Created by KGWH78 on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public struct LocalDataResults<T: Equatable>: PaginatedDataStoreResult, Equatable {

    public let items: [T]

    public let hasMoreItems: Bool

    public let nextIndex: Int?

    public init(items: [T], nextIndex: Int? = nil) {
        self.items = items
        self.nextIndex = nextIndex
        self.hasMoreItems = nextIndex != nil
    }

    public static func ==(lhs: LocalDataResults, rhs: LocalDataResults) -> Bool {
        return lhs.items == rhs.items && lhs.nextIndex == rhs.nextIndex && lhs.hasMoreItems == rhs.hasMoreItems
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

    public let limit: Int

    public init(items: [T], limit: Int = 0) {
        self.items = items
        self.limit = limit
    }

    public required init(arrayLiteral elements: T...) {
        self.items = elements
        self.limit = 0
    }

    public func retrieveItems(withLastKnownResults results: Result?, cancelToken: PromiseCancellationToken?) -> Promise<Result> {
        if let results = results, let currentIndex = results.nextIndex {
            let maxIndex = items.count
            let lastIndex = min(currentIndex + limit, maxIndex)
            let filteredItems = Array(items[currentIndex..<lastIndex])

            var nextIndex: Int?
            if let lastItem = filteredItems.last, limit > 0 && lastItem != items.last {
                if let lastItemIndex = items.index(of: lastItem) {
                    nextIndex = lastItemIndex + 1
                }
            }
            return Promise.value(LocalDataResults(items: filteredItems, nextIndex: nextIndex))
        } else {
            let filteredItems = limit > 0 ? Array(items.prefix(limit)) : items

            var nextIndex: Int?
            if let lastItem = filteredItems.last, lastItem != items.last {
                if let lastItemIndex = items.index(of: lastItem) {
                    nextIndex = lastItemIndex + 1
                }
            }

            return Promise.value(LocalDataResults(items: filteredItems, nextIndex: nextIndex))
        }
    }

    public func addItems(_ items: [Result.Item]) -> Promise<[Result.Item]> {
        return Promise { [unowned self] resolver in
            let indexes = items.indexes(where: { self.items.contains($0) })
            if indexes.count == 0 {
                self.items += items
                resolver.fulfill(items)

            } else {
                resolver.reject(LocalDataStoreError.duplicate)
            }
        }
    }

    public func removeItems(_ items: [Result.Item]) -> Promise<[Result.Item]> {
        return Promise { [unowned self] resolver in
            let indexes = self.items.indexes(where: { items.contains($0) })
            if indexes.count == items.count {
                items.forEach {
                    if let index = self.indexOfItem($0) {
                        self.items.remove(at: index)
                    }
                }

                resolver.fulfill(items)
            } else {
                resolver.reject(LocalDataStoreError.notFound)
            }
        }
    }

    public func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item> {
        return Promise { [unowned self] resolver in
            guard let index = self.indexOfItem(item) else {
                resolver.reject(LocalDataStoreError.notFound)
                return
            }

            guard self.indexOfItem(otherItem) == nil else {
                resolver.reject(LocalDataStoreError.duplicate)
                return
            }

            var items = self.items
            items.remove(at: index)
            items.insert(otherItem, at: index)

            self.items = items
            resolver.fulfill(otherItem)
        }
    }

    private func indexOfItem(_ item: Result.Item) -> Int? {
        return items.index(where: { $0 == item })
    }

}
