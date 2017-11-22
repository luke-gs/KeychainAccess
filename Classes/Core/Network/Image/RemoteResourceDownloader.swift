//
//  RemoteResourceDownloader.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire
import PromiseKit
import Unbox
import Cache

public class RemoteResourceDownloader<T: Codable> {

    public let apiManager: APIManager?

    private let resourceCache: Storage

    public let resourceDiskCacheConfig: DiskConfig

    private let barrierQueue: DispatchQueue
    private var inProgressPromises = [URL: Promise<T>]()

    /// If `APIManager` is not provided, the `APIManager.shared` will be used.
    /// This is to allow to pass in different APIManager setup if required while
    /// allowing using the global mutating `APIManager.shared`.
    public init(apiManager: APIManager? = nil, diskCacheConfig: DiskConfig = RemoteResourceDownloader.defaultDiskCacheConfig) {
        self.resourceDiskCacheConfig = diskCacheConfig
        // Use default `MemoryConfig`, it'll automatically clear anyway.

        self.apiManager = apiManager
        resourceCache = try! Storage(diskConfig: diskCacheConfig, memoryConfig: MemoryConfig())

        barrierQueue = DispatchQueue(label: "au.com.gridstone.RemoteResourceDownloader.Barrier.\(diskCacheConfig.name)", attributes: .concurrent)
    }

    /// Fetch image using the the `RemoteResourceDescribing`. The result will be cached
    /// and used for the subsequent requests.
    ///
    /// - Parameter imageResourceDescription: The description to download and cache the image
    /// - Returns: Promise to return a UIImage when the fetch is completed.
    @discardableResult
    public func fetchResource(using resourceDescription: RemoteResourceDescribing) -> Promise<T> {

        let downloadURL = resourceDescription.downloadURL
        let resourceRequest: Promise<T>

        if let request = fetchRequest(for: downloadURL) {
            resourceRequest = request
        } else {
            let request = fetchAndCacheResource(using: downloadURL)
            request.always { [weak self] in
                self?.set(fetchRequest: nil, for: downloadURL)
            }
            resourceRequest = request
            set(fetchRequest: request, for: downloadURL)
        }

        // Catch the error, it's very likely use case
        // that the fetcher wouldn't handle the error. So catch it here and do nothing.
        return resourceRequest.catch { _ in

        }
    }

    private func fetchAndCacheResource(using resourceDescription: RemoteResourceDescribing) -> Promise<T> {

        // Try to retrieve from cache first.
        func retrieveAndCacheResourcePromise() -> Promise<T> {
            let networkRequest = try! NetworkRequest(pathTemplate: resourceDescription.downloadURL.absoluteString, parameters: [:], isRelativePath: false)
            let promise: Promise<T> = try! _actualAPIManager.performRequest(networkRequest, using: CodableResponseSerializing())
            return promise.then { [weak self] image -> Promise<T> in

                if let strongSelf = self {
                    // Do nothing with the completion, it's not that important anyway.
                    strongSelf.resourceCache.async.setObject(image, forKey: resourceDescription.cacheKey, completion: { _ in })
                }

                return Promise(value: image)
            }
        }

        let isCached = try? resourceCache.existsObject(ofType: T.self, forKey: resourceDescription.cacheKey)

        if let isCached = isCached, isCached { // If cache for the key exists.

            let promise = Promise<T> { [weak self] fulfill, reject in
                guard let `self` = self else {
                    throw NSError.cancelledError()
                }
                self.resourceCache.async.entry(ofType: T.self, forKey: resourceDescription.cacheKey, completion: { result in
                    switch result {
                    case .value(let entry):
                        fulfill(entry.object)
                        break
                    case .error(let error):
                        reject(error)
                    }
                })
            }

            // If for whatever reasons fetching from cache failed, then go fetch from remote.
            return promise.recover { _ -> Promise<T> in
                return retrieveAndCacheResourcePromise()
            }
        } else {
            return retrieveAndCacheResourcePromise()
        }

    }

    // MARK: - Private utilities

    private func fetchRequest(for url: URL) -> Promise<T>? {
        var fetchRequest: Promise<T>?
        barrierQueue.sync {
            fetchRequest = inProgressPromises[url]
        }
        return fetchRequest
    }

    private func set(fetchRequest: Promise<T>?, for url: URL) {
        barrierQueue.async(flags: .barrier) { [weak self] in
            self?.inProgressPromises[url] = fetchRequest
        }
    }

    private var _actualAPIManager: APIManager {
        guard let apiManager = apiManager else {
            return APIManager.shared
        }
        return apiManager
    }
}

// MARK: - Default
extension RemoteResourceDownloader {

    public static var defaultCacheName: String { return "au.com.gridstone.RemoteResourceDownloader.cache.default" }

    // Default config has expiry of 1 hour and size of 100 MB.
    public static var defaultDiskCacheConfig: DiskConfig {
        let config = DiskConfig(name: RemoteResourceDownloader.defaultCacheName, expiry: .seconds(3600), maxSize: 150 * 1024 * 1024, directory: nil, protectionType: nil)
        return config
    }
}

public extension APIManager {

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return of specified type.
    public func performRequest(_ networkRequest: NetworkRequestType, imageScale: CGFloat? = nil) throws -> Promise<UIImage> {
        return try performRequest(networkRequest, using: ImageResponseSerializer(imageScale: imageScale))
    }

}
