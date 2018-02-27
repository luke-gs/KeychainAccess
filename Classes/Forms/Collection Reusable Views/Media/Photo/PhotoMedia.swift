//
//  PhotoMedia.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class PhotoMedia: MediaPreview {

    public let image: ImageLoadable?

    public init(asset: Media) {
        let image = UIImage(contentsOfFile: asset.url.path)
        self.image = image

        super.init(thumbnailImage: image, asset: asset)

        self.title = asset.title
        self.comments = asset.comments
        self.sensitive = asset.sensitive
    }


}
