//
//  PhotoPreview.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class PhotoPreview: MediaPreview {

    public let image: ImageLoadable?

    public init(asset: MediaAsset) {
        let image = UIImage(contentsOfFile: asset.url.path)
        self.image = image

        super.init(thumbnailImage: image, media: asset)
    }


}
