//
//  MediaDataSource.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import AVKit
import PromiseKit


public enum MediaGalleryState {
    case unknown
    case loading
    case completed(hasAdditionalItems: Bool)
    case error(Error)
}

public enum MediaGalleryRetrieveStyle {
    case reset
    case paginated
}

public protocol MediaGalleryViewModelable: class {

    var state: MediaGalleryState { get }

    var previews: [MediaPreviewable] { get }

    func controllerForPreview(_ preview: MediaPreviewable) -> UIViewController?

    func retrievePreviews(style: MediaGalleryRetrieveStyle)

    func removeMedia(_ media: Media) -> Promise<Bool>

    func replaceMedia(_ media: Media, with otherMedia: Media) -> Promise<Bool>

    func addMedia(_ media: Media) -> Promise<Bool>

}

extension MediaGalleryViewModelable {

    public func indexOfPreview(_ preview: MediaPreviewable) -> Int? {
        return previews.index(where: { $0 === preview })
    }

}

public let MediaGalleryDidChangeNotificationName = Notification.Name("MediaGalleryDidChangeNotificationName")


public class MediaGalleryCoordinatorViewModel<T: WritableDataStore>: MediaGalleryViewModelable where T.Result: PaginatedDataStoreResult, T.Result.Item == Media {

    public private(set) var state: MediaGalleryState = .unknown

    public private(set) var previews: [MediaPreviewable] = []

    public let storeCoordinator: DataStoreCoordinator<T>

    /// A registry of controllers for media items
    private var mediaControllers: [ObjectIdentifier: (UIViewController & MediaViewPresentable).Type] = [:]

    public init(storeCoordinator: DataStoreCoordinator<T>) {
        self.storeCoordinator = storeCoordinator

        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange(_:)), name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)

        if storeCoordinator.state == .unknown {
            storeCoordinator.retrieveItems()
        }

        genaratePreviews()
        updateState()
        registerDefaultControllers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)
    }

    open func previewForMedia(_ media: Media) -> MediaPreviewable {
        return PhotoMedia(thumbnailImage: AssetManager.shared.image(forKey: .info), image: AssetManager.shared.image(forKey: .info), asset: media)
    }

    public func controllerForPreview(_ preview: MediaPreviewable) -> UIViewController? {
        return mediaControllers[ObjectIdentifier(type(of: preview))]?.controller(forAsset: preview)
    }

    /// Register a controller type to a specific mediaPreviewable object
    ///
    /// - Parameters:
    ///   - controller: The type of the controller to register
    ///   - asset: The media the controller is to be registered against
    public func register(_ controller: (UIViewController & MediaViewPresentable).Type, for asset: MediaPreviewable.Type) {
        mediaControllers[ObjectIdentifier(asset)] = controller
    }

    /// Register default controllers for media items
    private func registerDefaultControllers() {
        register(AVMediaViewController.self, for: AudioMedia.self)
        register(MediaViewController.self, for: PhotoMedia.self)
        register(AVMediaViewController.self, for: VideoMedia.self)
    }

    @objc private func storeDidChange(_ notification: Notification) {
        genaratePreviews()
        updateState()

        NotificationCenter.default.post(name: MediaGalleryDidChangeNotificationName, object: self)
    }

    private func genaratePreviews() {
        previews = storeCoordinator.items.map { self.previewForMedia($0) }
    }

    private func updateState() {
        switch storeCoordinator.state {
        case .unknown:
            self.state = .unknown
        case .completed:
            self.state = .completed(hasAdditionalItems: storeCoordinator.hasMoreItems())
        case .loading:
            self.state = .loading
        case .error(let error):
            self.state = .error(error)
        }
    }

    // MARK: - Previews Retrieval

    public func retrievePreviews(style: MediaGalleryRetrieveStyle) {
        switch style {
        case .reset:
            storeCoordinator.retrieveItems()
        case .paginated:
            storeCoordinator.retrieveMoreItems()
        }
    }

    public func addMedia(_ media: Media) -> Promise<Bool> {
        return storeCoordinator.addItem(media).then { [weak self] _ -> Promise<[Media]> in
            guard let `self` = self else { return Promise(error: NSError(domain: "abc", code: 101, userInfo: [:]))}
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

    public func removeMedia(_ media: Media) -> Promise<Bool> {
        return storeCoordinator.removeItem(media).then { [weak self] _ -> Promise<[Media]> in
            guard let `self` = self else { return Promise(error: NSError(domain: "abc", code: 101, userInfo: [:]))}
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

    public func replaceMedia(_ media: Media, with otherMedia: Media) -> Promise<Bool> {
        return storeCoordinator.replaceItem(media, with: otherMedia).then { [weak self] _ -> Promise<[Media]> in
            guard let `self` = self else { return Promise(error: NSError(domain: "abc", code: 101, userInfo: [:]))}
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

}

//
//public let MediaDataSourceDidChangeNotificationName = Notification.Name(rawValue: "MediaDataSourceDidChange")
//
//
///// A media data source contains all the media items and provides convenience ways of querying these.
//open class MediaDataSource {
//
//    /// A collection of items
//    open private(set) var mediaItems: [MediaPreviewable]
//
//    /// A registry of controllers for media items
//    open private(set) var mediaControllers: [ObjectIdentifier: (UIViewController & MediaViewPresentable).Type] = [:]
//
//    /// Create a new data source.
//    ///
//    /// - Parameter mediaItems: A collection of media items.
//    public init(mediaItems: [MediaPreviewable] = []) {
//        self.mediaItems = mediaItems
//        registerDefaultControllers()
//    }
//
//    /// Return the total number of media items.
//    ///
//    /// - Returns: The count of media items.
//    open func numberOfMediaItems() -> Int {
//        return mediaItems.count
//    }
//
//    /// Find the media item by its index in the collection. If index is out of bound, nil is return.
//    ///
//    /// - Parameter index: The index of media item to find.
//    /// - Returns: A media item at the speficied index if found. Nil otherwise.
//    open func mediaItemAtIndex(_ index: Int) -> MediaPreviewable? {
//        guard index >= 0 && index < mediaItems.count else { return nil }
//        return mediaItems[index]
//    }
//
//    /// Find the index of the media item in the collection.
//    ///
//    /// - Parameter mediaItem: The media item.
//    /// - Returns: The index if found. Nil otherwise.
//    open func indexOfMediaItem(_ mediaItem: MediaPreviewable) -> Int? {
//        return mediaItems.index(where: { $0 === mediaItem })
//    }
//
//    /// Returns a media item at a specific index.
//    ///
//    /// - Parameter index: The index of media item to find.
//    open subscript(index: Int) -> MediaPreviewable? {
//        get {
//            return mediaItemAtIndex(index)
//        }
//    }
//
//    /// Replace media item with another item.
//    ///
//    /// - Parameters:
//    ///   - mediaItem: The media item to be replaced.
//    ///   - otherMediaItem: The media item to replace.
//    @available(iOS, deprecated)
//    open func replaceMediaItem(_ mediaItem: MediaPreviewable, with otherMediaItem: MediaPreviewable) {
//        if let index = indexOfMediaItem(mediaItem) {
//            mediaItems.remove(at: index)
//            mediaItems.insert(otherMediaItem, at: index)
//            NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
//        }
//    }
//
//    /// Add a media item to the collection. A notification with the name
//    /// 'MediaDataSourceDidChangeNotificationName' is sent on done.
//    ///
//    /// - Parameter mediaItem: The media item to add.
//    @available(iOS, deprecated)
//    open func addMediaItem(_ mediaItem: MediaPreviewable) {
//        mediaItems.append(mediaItem)
//        NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
//    }
//
//    /// Remove a media item from the collection. A notification with the name
//    /// 'MediaDataSourceDidChangeNotificationName' is sent on done. No notification will be
//    /// sent out if the media item is not in the collection.
//    ///
//    /// - Parameter mediaItem: The media item to remove
//    @available(iOS, deprecated)
//    open func removeMediaItem(_ mediaItem: MediaPreviewable) {
//        if let index = indexOfMediaItem(mediaItem) {
//            mediaItems.remove(at: index)
//            NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
//        }
//    }
//
//
//    /// Register a controller type to a specific mediaPreviewable object
//    ///
//    /// - Parameters:
//    ///   - controller: The type of the controller to register
//    ///   - asset: The media the controller is to be registered against
//    open func register(_ controller: (UIViewController & MediaViewPresentable).Type, for asset: MediaPreviewable.Type) {
//        mediaControllers[ObjectIdentifier(asset)] = controller
//    }
//
//    /// Register default controllers for media items
//    private func registerDefaultControllers() {
//        register(AVMediaViewController.self, for: AudioMedia.self)
//        register(MediaViewController.self, for: PhotoMedia.self)
//        register(AVMediaViewController.self, for: VideoMedia.self)
//    }
//
//    // MARK: - State
//
//    public enum State {
//        case unknown
//        case loading
//        case completed
//        case error(Error)
//
//    }
//
//    @available(iOS, deprecated)
//    open private(set) var state: State = .unknown {
//        didSet {
//            NotificationCenter.default.post(name: MediaDataSourceDidChangeNotificationName, object: self, userInfo: nil)
//        }
//    }
//
//    @available(iOS, deprecated)
//    open func loadMoreItems() -> Promise<[MediaPreviewable]>? {
//        state = .loading
//
//        return Promise(resolvers: { [weak self] (fullfill, reject) in
//            if arc4random_uniform(50) > 10 {
//                let url = URL(fileURLWithPath: Bundle.main.resourcePath! + "/Avatar 1.png")
//
//                let extra: [MediaPreviewable] = [
//                    PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Jeff 01", comments: "Sexy Jeff 01", isSensitive: false)),
//                    PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Jeff 02", comments: "Sexy Jeff 02", isSensitive: true)),
//                    PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Jeff 03", comments: "Sexy Jeff 03", isSensitive: true))
//                ]
//
//
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.3) {
//                    self?.mediaItems += extra
//                    self?.state = .unknown
//                    fullfill(extra)
//                }
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.3) { [weak self] in
//                    let error = NSError(domain: "Broken", code: 1000, userInfo: [NSLocalizedDescriptionKey: "This is broken sir"])
//                    self?.state = .error(error)
//                    reject(error)
//                }
//            }
//        })
//    }
//
//}
//
//extension MediaDataSource.State: Equatable {
//
//    public static func ==(lhs: MediaDataSource.State, rhs: MediaDataSource.State) -> Bool {
//        switch (lhs, rhs) {
//        case (.unknown, .unknown): return true
//        case (.loading, .loading): return true
//        case (.completed, .completed): return true
//        case (.error(let error1), .error(let error2)): return (error1 as NSError) == (error2 as NSError)
//        default: return false
//        }
//    }
//
//}

