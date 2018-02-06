//
//  PhotoMedia.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class PhotoMedia: MediaAsset {

    enum PhotoCodingKeys: String, CodingKey {
        case image
    }

    public let image: ImageLoadable?

    public init(thumbnailImage: ImageLoadable?,
                image: ImageLoadable?,
                imageURL: URL? = nil,
                title: String? = nil,
                comments: String? = nil,
                sensitive: Bool = false) {

        self.image = image

        super.init(thumbnailImage: thumbnailImage,
                   assetURL: imageURL,
                   title: title,
                   comments: comments,
                   isSensitive: sensitive)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotoCodingKeys.self)
        image = try container.decode(ImageWrapper.self, forKey: PhotoCodingKeys.image).image

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PhotoCodingKeys.self)

        var wrappedImage: ImageWrapper?
        image?.loadImage(completion: { (imageSizing) in
            if let image = imageSizing.sizing().image {
                wrappedImage = ImageWrapper(image: image)
            }
        })
        if let wrappedImage = wrappedImage {
            try container.encode(wrappedImage, forKey: .image)
        }

        try super.encode(to: encoder)
    }

}
