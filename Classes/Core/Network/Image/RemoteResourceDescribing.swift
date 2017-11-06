//
//  RemoteResourceDescribing.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

// `RemoteResourceDescribing` describes where the resource can be downloaded from network.
// and how it could be cached or retrived from cache.
public protocol RemoteResourceDescribing {
    var downloadURL: URL { get }
    var cacheKey: String { get }
}

// Default implementation of `RemoteResourceDescribing`, a simple `downloadURL` and `cacheKey` pair.
public struct ImageRemoteResourceDescription: RemoteResourceDescribing {

    public let downloadURL: URL
    public let cacheKey: String

    /// Initialise a `ImageRemoteResourceDescription`.
    ///
    /// - Parameters:
    ///   - downloadURL: The URL where the image can be retrieved from.
    ///   - cacheKey: The key to store and retrieve the image from cache.
    ///               Default to use the `URL.absoluteString` as the key.
    public init(downloadURL: URL, cacheKey: String? = nil) {
        self.downloadURL = downloadURL
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
    }

}

// Convenience extension to allow URL to be used to fetch and cache resource.
// The `self` will be used as `downloadURL` and the `self.absoluteString` will be used as `cacheKey`.
extension URL: RemoteResourceDescribing {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}
