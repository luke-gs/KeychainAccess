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

    public init(thumbnailImage: ImageLoadable?,
                image: ImageLoadable?,
                asset: Media) {

        self.image = image
        super.init(thumbnailImage: thumbnailImage, asset: asset)
    }
}
