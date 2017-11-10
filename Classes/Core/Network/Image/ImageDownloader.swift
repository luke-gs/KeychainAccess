//
//  ImageDownloader.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire
import PromiseKit
import Cache

public class ImageDownloader {

    public static let `default` = ImageDownloader()

    public let apiManager: APIManager?

    private let imageCache: Storage

    public let imageDiskCacheConfig: DiskConfig

    private let barrierQueue: DispatchQueue
    private var inProgressPromises = [URL: Promise<UIImage>]()

    /// If `APIManager` is not provided, the `APIManager.shared` will be used.
    /// This is to allow to pass in different APIManager setup if required while
    /// allowing using the global mutating `APIManager.shared`.
    public init(apiManager: APIManager? = nil, diskCacheConfig: DiskConfig = ImageDownloader.defaultDiskCacheConfig) {
        self.imageDiskCacheConfig = diskCacheConfig
        // Use default `MemoryConfig`, it'll automatically clear anyway.

        self.apiManager = apiManager
        imageCache = try! Storage(diskConfig: diskCacheConfig, memoryConfig: MemoryConfig())

        barrierQueue = DispatchQueue(label: "au.com.gridstone.ImageDownloader.Barrier.\(diskCacheConfig.name)", attributes: .concurrent)
    }

    /// Fetch image using the the `RemoteResourceDescribing`. The result will be cached
    /// and used for the subsequent requests.
    ///
    /// - Parameter imageResourceDescription: The description to download and cache the image
    /// - Returns: Promise to return a UIImage when the fetch is completed.
    @discardableResult
    public func fetchImage(using imageResourceDescription: RemoteResourceDescribing) -> Promise<UIImage> {

        let downloadURL = imageResourceDescription.downloadURL
        let imageRequest: Promise<UIImage>

        if let request = fetchRequest(for: downloadURL) {
            imageRequest = request
        } else {
            let request = fetchAndCacheImage(using: downloadURL)
            request.always { [weak self] in
                self?.set(fetchRequest: nil, for: downloadURL)
            }
            imageRequest = request
            set(fetchRequest: request, for: downloadURL)
        }

        // Catch the error, it's very likely use case
        // that the fetcher wouldn't handle the error. So catch it here and do nothing.
        return imageRequest.catch { _ in

        }
    }

    private func fetchAndCacheImage(using imageResourceDescription: RemoteResourceDescribing) -> Promise<UIImage> {

        // Try to retrieve from cache first.
        func retrieveAndCacheImagePromise() -> Promise<UIImage> {
            let networkRequest = try! NetworkRequest(pathTemplate: imageResourceDescription.downloadURL.absoluteString, parameters: [:], isRelativePath: false)
            let promise: Promise<UIImage> = try! _actualAPIManager.performRequest(networkRequest)

            return promise.then { [weak self] image -> Promise<UIImage> in

                if let strongSelf = self {
                    let imageWrapper = ImageWrapper(image: image)
                    // Do nothing with the completion, it's not that important anyway.
                    strongSelf.imageCache.async.setObject(imageWrapper, forKey: imageResourceDescription.cacheKey, completion: { _ in })
                }

                return Promise(value: image)
            }
        }

        let isCached = try? imageCache.existsObject(ofType: ImageWrapper.self, forKey: imageResourceDescription.cacheKey)

        if let isCached = isCached, isCached { // If cache for the key exists.

            let promise = Promise<UIImage> { [weak self] fulfill, reject in
                guard let `self` = self else {
                    throw NSError.cancelledError()
                }
                self.imageCache.async.entry(ofType: ImageWrapper.self, forKey: imageResourceDescription.cacheKey, completion: { result in
                    switch result {
                    case .value(let entry):
                        fulfill(entry.object.image)
                    case .error(let error):
                        reject(error)
                    }
                })
            }

            // If for whatever reasons fetching from cache failed, then go fetch from remote.
            return promise.recover { _ -> Promise<UIImage> in
                return retrieveAndCacheImagePromise()
            }
        } else {
            return retrieveAndCacheImagePromise()
        }

    }

    // MARK: - Private utilities

    private func fetchRequest(for url: URL) -> Promise<UIImage>? {
        var fetchRequest: Promise<UIImage>?
        barrierQueue.sync {
            fetchRequest = inProgressPromises[url]
        }
        return fetchRequest
    }

    private func set(fetchRequest: Promise<UIImage>?, for url: URL) {
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
extension ImageDownloader {

    public static let defaultCacheName: String = "au.com.gridstone.ImageDownloader.cache.default"

    // Default config has expiry of 1 hour and size of 100 MB.
    public static var defaultDiskCacheConfig: DiskConfig {
        let config = DiskConfig(name: ImageDownloader.defaultCacheName, expiry: .seconds(3600), maxSize: 150 * 1024 * 1024, directory: nil, protectionType: nil)
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
