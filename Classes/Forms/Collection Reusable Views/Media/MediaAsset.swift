//
//  Media.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Cache

public class MediaAsset: MediaPreviewable, Codable {

    enum CodingKeys: String, CodingKey {
        case thumbnailImage
        case assetURL
        case title
        case comments
        case sensitive
    }

    public let thumbnailImage: ImageLoadable?

    public let assetURL: URL?

    public var title: String?
    public var comments: String?

    public var sensitive: Bool

    init(thumbnailImage: ImageLoadable?, assetURL: URL?, title: String?, comments: String?, isSensitive: Bool) {
        self.assetURL = assetURL
        self.thumbnailImage = thumbnailImage
        self.title = title
        self.comments = comments
        self.sensitive = isSensitive
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var wrappedImage: ImageWrapper?
        thumbnailImage?.loadImage(completion: { (imageSizing) in
            if let image = imageSizing.sizing().image {
                wrappedImage = ImageWrapper(image: image)
            }
        })
        if let wrappedImage = wrappedImage {
            try container.encode(wrappedImage, forKey: .thumbnailImage)
        }

        try container.encode(sensitive, forKey: .sensitive)
        try container.encode(title, forKey: .title)
        try container.encode(assetURL, forKey: .assetURL)
        try container.encode(comments, forKey: .comments)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        thumbnailImage = try container.decode(ImageWrapper.self, forKey: .thumbnailImage).image
        title = try container.decode(String?.self, forKey: .title)
        comments = try container.decode(String?.self, forKey: .comments)
        assetURL = try container.decode(URL?.self, forKey: .assetURL)
        sensitive = try container.decode(Bool.self, forKey: .sensitive)
    }

}
