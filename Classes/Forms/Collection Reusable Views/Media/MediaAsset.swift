//
//  Media.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Cache


public enum MediaType: Int, Codable {
    case video
    case audio
    case photo
}


public class Media: Codable {
    public let identifier: String
    public let type: MediaType

    public let url: URL
    public var title: String?
    public var comments: String?
    public var sensitive: Bool
    
    public init(identifier: String = UUID().uuidString, url: URL, type: MediaType, title: String? = nil, comments: String? = nil, isSensitive: Bool = false) {
        self.identifier = identifier
        self.type = type
        self.url = url
        self.title = title
        self.comments = comments
        self.sensitive = isSensitive
    }
}

extension Media: Hashable {

    public var hashValue: Int {
        return identifier.hashValue ^ type.rawValue.hashValue ^ url.hashValue ^ (title?.hashValue ?? 0) ^ (comments?.hashValue ?? 0) ^ sensitive.hashValue
    }

    static public func ==(lhs: Media, rhs: Media) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.type == rhs.type &&
            lhs.url == rhs.url &&
            lhs.title == rhs.title &&
            lhs.comments == rhs.comments &&
            lhs.sensitive == rhs.sensitive
    }

}

public class MediaPreview: MediaPreviewable {

    public var sensitive: Bool = false
    public var comments: String?
    public var thumbnailImage: ImageLoadable?
    public var title: String?

    public let asset: Media

    public init(thumbnailImage: ImageLoadable? = nil, asset: Media) {
        self.asset = asset
        self.thumbnailImage = thumbnailImage
    }

}
