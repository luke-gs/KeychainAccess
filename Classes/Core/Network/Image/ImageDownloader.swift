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

public class ImageDownloader {

    private let _downloader = RemoteResourceDownloader<ImageWrapper>()
    public static let `default` = ImageDownloader()
    private init() {}

    @discardableResult
    public func fetch(for keypath: RemoteResourceDescribing) -> Promise<UIImage> {
        return _downloader.fetchResource(using: keypath.downloadURL).then {
            return Promise<UIImage>(value: $0.image)
        }
    }
}
