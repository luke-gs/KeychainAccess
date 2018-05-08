//
//  MediaDataStore.swift
//  MPOLKit
//
//  Created by QHMW64 on 22/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

protocol MediaContainer {
    var media: [Media] { get set }

    func add(_ media: [Media])
    func remove(_ media: [Media])
}

class MediaStorageDatastore<T: Media>: WritableDataStore {

    typealias ArrayLiteralElement = T
    typealias Result = LocalDataResults<T>

    private var container: MediaContainer

    public private(set) var items: [T]

    // No media manager, means something is terrible wrong, might as well crash.
    private lazy var manager: MediaFileManager = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("assets", isDirectory: true)
        return try! MediaFileManager(basePath: directory)
    }()

    public init(items: [T], container: MediaContainer) {
        self.items = items
        self.container = container
    }

    func retrieveItems(withLastKnownResults results: LocalDataResults<T>?, cancelToken: PromiseCancellationToken?) -> Promise<LocalDataResults<T>> {
        return Promise.value(LocalDataResults(items: items))
    }


    func addItems(_ toBeAddedItems: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
        return Promise { [unowned self] resolver in
            let indexes = toBeAddedItems.indexes(where: { toBeAdded in
                self.items.contains(where: { toBeCompared -> Bool in
                    return toBeAdded.identifier == toBeCompared.identifier
                })
            })

            if indexes.isEmpty {
                self.items += toBeAddedItems
                for item in toBeAddedItems {
                    do {
                        let url = manager.directory(forMedia: item.type)
                        let destination = url.appendingPathComponent(item.url.lastPathComponent)
                        try manager.copy(url: item.url, to: destination)
                        if let index = indexOfItem(item) {
                            self.items[index].url = destination
                        }
                    } catch {
                        resolver.reject(LocalDataStoreError.duplicate)
                        return
                    }
                }
                container.add(toBeAddedItems)
                resolver.fulfill(toBeAddedItems)
            } else {
                resolver.reject(LocalDataStoreError.duplicate)
            }
        }
    }

    func removeItems(_ toBeRemovedItems: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
        return Promise { [unowned self] resolver in

            let indexes = toBeRemovedItems.indexes(where: { toBeRemoved in
                self.items.contains(where: { toBeCompared -> Bool in
                    return toBeRemoved.identifier == toBeCompared.identifier
                })
            })

            if indexes.count == toBeRemovedItems.count {
                toBeRemovedItems.forEach {
                    if let index = self.indexOfItem($0) {
                        self.items.remove(at: index)

                        do {
                            try FileManager.default.removeItem(at: $0.url)
                        } catch {
                            resolver.reject(LocalDataStoreError.notFound)
                            return
                        }
                    }
                }
                container.remove(toBeRemovedItems)
                resolver.fulfill(toBeRemovedItems)
            } else {
                resolver.reject(LocalDataStoreError.notFound)
            }
        }
    }


    /// Replace the item with different item with the same identifier.
    ///
    /// - Parameters:
    ///   - item: Existing item to be replaced.
    ///   - otherItem: The replacement item.
    /// - Returns: Promise with the value of replacement item when successful. It will be an error if the replacement doesn't have the same identifier with the existing.
    public func replaceItem(_ item: Result.Item, with otherItem: Result.Item) -> Promise<Result.Item> {
        return Promise { [unowned self] resolver in

            // Can't replace item that doesn't exist
            guard let index = self.indexOfItem(item) else {
                resolver.reject(LocalDataStoreError.notFound)
                return
            }

            // Have to replace items with same identifiers.
            guard item.identifier == otherItem.identifier else {
                resolver.reject(LocalDataStoreError.duplicate)
                return
            }

            // If item doesn't have the same backing URL, remove the old one
            // and copy the new one
            if item.url != otherItem.url {
                do {
                    let url = manager.directory(forMedia: otherItem.type)
                    let destination = url.appendingPathComponent(otherItem.url.lastPathComponent)

                    try manager.copy(url: item.url, to: destination)

                } catch {
                    resolver.reject(LocalDataStoreError.duplicate)
                    return
                }

                // Same as removing, ignore the removal error.
                try? FileManager.default.removeItem(at: item.url)
            }

            var items = self.items
            items.remove(at: index)
            items.insert(otherItem, at: index)
            self.items = items

            container.remove([item])
            container.add([otherItem])

            resolver.fulfill(otherItem)

        }
    }

    private func indexOfItem(_ item: Result.Item) -> Int? {
        return items.index(where: { $0 == item })
    }
}
