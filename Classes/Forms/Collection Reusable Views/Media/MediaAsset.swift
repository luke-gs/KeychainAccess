//
//  Media.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Cache

public enum MediaType: Int, Codable, Hashable {
    case video
    case audio
    case photo
}

// TODO: Doesn't have to be a class, struct is probably a better fit.
open class MediaAsset: NSObject, NSCopying, Codable {
    
    public let identifier: String
    public let type: MediaType

    public var url: URL
    public var title: String?
    public var comments: String?
    public var sensitive: Bool
    
    public var createdDate: Date?
    
    public init(identifier: String = UUID().uuidString, url: URL, type: MediaType, title: String? = nil, comments: String? = nil, sensitive: Bool = false, createdDate: Date? = nil) {
        self.identifier = identifier
        self.type = type
        self.url = url
        self.title = title
        self.comments = comments
        self.sensitive = sensitive
        self.createdDate = createdDate
    }

    private convenience init(otherMedia: MediaAsset) {
        self.init(identifier: otherMedia.identifier,
                  url: otherMedia.url,
                  type: otherMedia.type,
                  title: otherMedia.title,
                  comments: otherMedia.comments,
                  sensitive: otherMedia.sensitive,
                  createdDate: otherMedia.createdDate)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return MediaAsset(otherMedia: self)
    }

    open override var hashValue: Int {
        let idHash = identifier.hashValue
        let typeHash = type.rawValue.hashValue
        let urlHash = url.hashValue
        let titleHash = (title?.hashValue ?? 0)
        let commentsHash = (comments?.hashValue ?? 0)
        let sensitiveHash = sensitive.hashValue
        let createdHash = (createdDate?.hashValue ?? 0)

        return idHash
            ^ typeHash
            ^ urlHash
            ^ titleHash
            ^ commentsHash
            ^ sensitiveHash
            ^ createdHash
    }

    open override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MediaAsset else {
            return false
        }
        let lhs = self
        return lhs.identifier == rhs.identifier &&
            lhs.type == rhs.type &&
            lhs.url == rhs.url &&
            lhs.title == rhs.title &&
            lhs.comments == rhs.comments &&
            lhs.sensitive == rhs.sensitive &&
            lhs.createdDate == rhs.createdDate
    }
}

extension MediaAsset {
    static public func ==(lhs: MediaAsset, rhs: MediaAsset) -> Bool {
        return lhs.isEqual(rhs)
    }
}

extension MediaAsset: DefaultNSCopying { }

public class MediaPreview: MediaPreviewable {

    public var sensitive: Bool = false
    public var comments: String?
    public var thumbnailImage: ImageLoadable?
    public var title: String?

    public let media: MediaAsset

    public init(thumbnailImage: ImageLoadable? = nil, media: MediaAsset) {
        self.media = media
        self.thumbnailImage = thumbnailImage
        self.title = media.title
        self.comments = media.comments
        self.sensitive = media.sensitive
    }

}
