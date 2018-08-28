//
//  ImageDownloader.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import Cache

// Utilised to download codeable images (base64, json)
public class DecodableImageDownloader {

    private let _downloader = RemoteResourceDownloader<ImageWrapper, CodableResponseSerializing<ImageWrapper>>(responseSerializing: CodableResponseSerializing())
    public static let `default` = DecodableImageDownloader()
    private init() {}

    @discardableResult
    public func fetch(for keypath: RemoteResourceDescribing) -> Promise<UIImage> {
        return _downloader.fetchResource(using: keypath.downloadURL).then {
            return Promise<UIImage>.value($0.image)
        }
    }
}

// Utilised to download non-codeable images (jpg, png files etc.)
public class ImageDownloader {

    private let _downloader = RemoteResourceDownloader(responseSerializing: ImageWrapperResponseSerializer())
    public static let `default` = ImageDownloader()
    private init() {}

    @discardableResult
    public func fetch(for keypath: RemoteResourceDescribing) -> Promise<UIImage> {
        return _downloader.fetchResource(using: keypath.downloadURL).then {
            return Promise<UIImage>.value($0.image)
        }
    }
}
