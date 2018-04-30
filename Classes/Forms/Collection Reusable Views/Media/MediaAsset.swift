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

open class Media: Codable {
    
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

    public convenience init(otherMedia: Media) {
        self.init(identifier: otherMedia.identifier,
                  url: otherMedia.url,
                  type: otherMedia.type,
                  title: otherMedia.title,
                  comments: otherMedia.comments,
                  sensitive: otherMedia.sensitive,
                  createdDate: otherMedia.createdDate)
    }
    
}

extension Media: Hashable {

    public var hashValue: Int {
        
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

    static public func ==(lhs: Media, rhs: Media) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.type == rhs.type &&
            lhs.url == rhs.url &&
            lhs.title == rhs.title &&
            lhs.comments == rhs.comments &&
            lhs.sensitive == rhs.sensitive &&
            lhs.createdDate == rhs.createdDate
    }

}

public class MediaPreview: MediaPreviewable {

    public var sensitive: Bool = false
    public var comments: String?
    public var thumbnailImage: ImageLoadable?
    public var title: String?

    public let media: Media

    public init(thumbnailImage: ImageLoadable? = nil, media: Media) {
        self.media = media
        self.thumbnailImage = thumbnailImage
        self.title = media.title
        self.comments = media.comments
        self.sensitive = media.sensitive
    }

}
