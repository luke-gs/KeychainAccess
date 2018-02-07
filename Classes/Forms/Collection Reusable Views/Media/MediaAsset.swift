//
//  Media.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class Media: Codable {
    public let url: URL
    public var title: String?
    public var comments: String?
    public var sensitive: Bool

    public init(url: URL, title: String? = nil, comments: String? = nil, isSensitive: Bool = false) {
        self.url = url
        self.title = title
        self.comments = comments
        self.sensitive = isSensitive
    }
}


public class MediaPreview: MediaPreviewable {

    public var sensitive: Bool = false
    public var comments: String?
    public var thumbnailImage: ImageLoadable?
    public var title: String?

    let asset: Media

    public init(thumbnailImage: ImageLoadable? = nil, asset: Media) {
        self.asset = asset
        self.thumbnailImage = thumbnailImage
    }

}
