//
//  MediaDataSource.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public let MediaDataSourceDidChangeNotificationName = Notification.Name(rawValue: "MediaDataSourceDidChange")


/// A media data source contains all the media items and provides convenience ways of querying these.
open class MediaDataSource {

    /// A collection of items
    open private(set) var mediaItems: [MediaPreviewable]

    /// A registry of controllers for media items
    open private(set) var mediaControllers: [ObjectIdentifier: (UIViewController & MediaViewPresentable).Type] = [:]

    /// Create a new data source.
    ///
    /// - Parameter mediaItems: A collection of media items.
    public init(mediaItems: [MediaPreviewable] = []) {
        self.mediaItems = mediaItems
        registerDefaultControllers()
    }

    /// Return the total number of media items.
    ///
    /// - Returns: The count of media items.
    open func numberOfMediaItems() -> Int {
        return mediaItems.count
    }

    /// Find the media item by its index in the collection. If index is out of bound, nil is return.
    ///
    /// - Parameter index: The index of media item to find.
    /// - Returns: A media item at the speficied index if found. Nil otherwise.
    open func mediaItemAtIndex(_ index: Int) -> MediaPreviewable? {
        guard index >= 0 && index < mediaItems.count else { return nil }
        return mediaItems[index]
    }

    /// Find the index of the media item in the collection.
    ///
    /// - Parameter mediaItem: The media item.
    /// - Returns: The index if found. Nil otherwise.
    open func indexOfMediaItem(_ mediaItem: MediaPreviewable) -> Int? {
        return mediaItems.index(where: { $0 === mediaItem })
    }

    /// Returns a media item at a specific index.
    ///
    /// - Parameter index: The index of media item to find.
    open subscript(index: Int) -> MediaPreviewable? {
        get {
            return mediaItemAtIndex(index)
        }
    }

    /// Replace media item with another item.
    ///
    /// - Parameters:
    ///   - mediaItem: The media item to be replaced.
    ///   - otherMediaItem: The media item to replace.
    open func replaceMediaItem(_ mediaItem: MediaPreviewable, with otherMediaItem: MediaPreviewable) {
        if let index = indexOfMediaItem(mediaItem) {
            mediaItems.remove(at: index)
            mediaItems.insert(otherMediaItem, at: index)
            NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
        }
    }

    /// Add a media item to the collection. A notification with the name
    /// 'MediaDataSourceDidChangeNotificationName' is sent on done.
    ///
    /// - Parameter mediaItem: The media item to add.
    open func addMediaItem(_ mediaItem: MediaPreviewable) {
        mediaItems.append(mediaItem)
        NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
    }

    /// Remove a media item from the collection. A notification with the name
    /// 'MediaDataSourceDidChangeNotificationName' is sent on done. No notification will be
    /// sent out if the media item is not in the collection.
    ///
    /// - Parameter mediaItem: The media item to remove
    open func removeMediaItem(_ mediaItem: MediaPreviewable) {
        if let index = indexOfMediaItem(mediaItem) {
            mediaItems.remove(at: index)
            NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
        }
    }


    /// Register a controller type to a specific mediaPreviewable object
    ///
    /// - Parameters:
    ///   - controller: The type of the controller to register
    ///   - asset: The media the controller is to be registered against
    open func register(_ controller: (UIViewController & MediaViewPresentable).Type, for asset: MediaPreviewable.Type) {
        mediaControllers[ObjectIdentifier(asset)] = controller
    }

    /// Register default controllers for media items
    private func registerDefaultControllers() {
        register(AVMediaViewController.self, for: AudioMedia.self)
        register(MediaViewController.self, for: PhotoMedia.self)
        register(AVMediaViewController.self, for: VideoMedia.self)
    }

}
