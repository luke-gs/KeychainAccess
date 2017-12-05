//
//  PhotoMedia.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation



public class PhotoMedia: MediaPreviewable {

    public let thumbnailImage: ImageLoadable?

    public let image: ImageLoadable?

    public var title: String?

    public var sensitive: Bool

    public init(thumbnailImage: ImageLoadable?, image: ImageLoadable?, title: String? = nil, sensitive: Bool = false) {
        self.thumbnailImage = thumbnailImage
        self.image = image
        self.title = title
        self.sensitive = sensitive
    }

}
