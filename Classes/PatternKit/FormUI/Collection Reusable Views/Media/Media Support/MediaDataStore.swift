//
//  MediaDataStore.swift
//  MPOLKit
//
//  Created by QHMW64 on 22/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public protocol MediaContainer {
    var media: [MediaAsset] { get set }

    func add(_ media: [MediaAsset])
    func remove(_ media: [MediaAsset])
}

public class MediaStorageDatastore<T: MediaAsset>: WritableDataStore {

    typealias ArrayLiteralElement = T
    public typealias Result = LocalDataResults<T>

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

    public func retrieveItems(withLastKnownResults results: LocalDataResults<T>?, cancelToken: PromiseCancellationToken?) -> Promise<LocalDataResults<T>> {
        return Promise.value(LocalDataResults(items: items))
    }


    public func addItems(_ toBeAddedItems: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
        return Promise { [unowned self] resolver in
            let indexes = toBeAddedItems.indexes(where: { toBeAdded in
                self.items.contains(where: { toBeCompared -> Bool in
                    return toBeAdded.identifier == toBeCompared.identifier
                })
            })

            if indexes.isEmpty {
                let copied = toBeAddedItems.clone()
                for item in copied {
                    do {
                        let url = manager.directory(forMedia: item.type)
                        let destination = url.appendingPathComponent(item.url.lastPathComponent)
                        try manager.copy(url: item.url, to: destination)
                        item.url = destination
                    } catch {
                        resolver.reject(LocalDataStoreError.duplicate)
                        return
                    }
                }
                self.items += copied
                container.add(copied)
                resolver.fulfill(copied)
            } else {
                resolver.reject(LocalDataStoreError.duplicate)
            }
        }
    }

    public func removeItems(_ toBeRemovedItems: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
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
                        // If it fails to remove, who cares, it doesn't exist anymore.
                        try? FileManager.default.removeItem(at: $0.url)
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
            let copied: Result.Item = otherItem.copy()
            if item.url != copied.url {
                do {
                    let url = manager.directory(forMedia: copied.type)
                    let destination = url.appendingPathComponent(copied.url.lastPathComponent)

                    try manager.copy(url: copied.url, to: destination)
                    copied.url = url

                } catch {
                    resolver.reject(LocalDataStoreError.duplicate)
                    return
                }

                // Same as removing, ignore the removal error.
                try? FileManager.default.removeItem(at: item.url)
            }

            var items = self.items
            items.remove(at: index)
            items.insert(copied, at: index)
            self.items = items

            container.remove([item])
            container.add([copied])

            resolver.fulfill(copied)

        }
    }

    private func indexOfItem(_ item: Result.Item) -> Int? {
        return items.index(where: { $0 == item })
    }
}
