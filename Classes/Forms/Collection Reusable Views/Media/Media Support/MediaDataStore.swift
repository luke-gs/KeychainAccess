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

    private lazy var manager: MediaFileManager? = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("assets", isDirectory: true)
        return try? MediaFileManager(basePath: directory)
    }()

    public init(items: [T], container: MediaContainer) {
        self.items = items
        self.container = container
    }

    func retrieveItems(withLastKnownResults results: LocalDataResults<T>?, cancelToken: PromiseCancellationToken?) -> Promise<LocalDataResults<T>> {
        return Promise(value: LocalDataResults(items: items))
    }


    func addItems(_ items: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
        return Promise { [unowned self] fullfill, reject in
            let indexes = items.indexes(where: { self.items.contains($0) })
            if indexes.count == 0 {
                self.items += items
                for item in items {
                    do {
                        if let url = manager?.directory(forMedia: item.type) {
                            let destination = url.appendingPathComponent(item.url.lastPathComponent)
                            try manager?.move(url: item.url, to: destination)
                            if let index = indexOfItem(item) {
                                self.items[index].url = destination
                            }
                        }
                    } catch {
                        reject(LocalDataStoreError.duplicate)
                    }
                }
                container.add(items)
                fullfill(items)
            } else {
                reject(LocalDataStoreError.duplicate)
            }
        }
    }

    func removeItems(_ items: [MediaStorageDatastore<T>.Result.Item]) -> Promise<[MediaStorageDatastore<T>.Result.Item]> {
        return Promise { [unowned self] fullfill, reject in
            let indexes = self.items.indexes(where: { items.contains($0) })
            if indexes.count == items.count {
                items.forEach {
                    if let index = self.indexOfItem($0) {
                        self.items.remove(at: index)

                        do {
                            try FileManager.default.removeItem(at: $0.url)
                        } catch {
                            reject(LocalDataStoreError.notFound)
                        }
                    }
                }
                container.remove(items)
                fullfill(items)
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

            let existingURL = items[index].url
            do {
                try manager?.move(url: otherItem.url, to: existingURL)
            } catch {
                reject(LocalDataStoreError.notSupported)
            }

            self.items = items
            fullfill(otherItem)
        }
    }

    private func indexOfItem(_ item: Result.Item) -> Int? {
        return items.index(where: { $0 == item })
    }

}

