//
//  MediaGalleryViewModelable.swift
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

    func removeMedia(_ media: [Media]) -> Promise<Bool>

    func replaceMedia(_ media: Media, with otherMedia: Media) -> Promise<Bool>

    func addMedia(_ media: [Media]) -> Promise<Bool>

    // State information

    func titleForState(_ state: MediaGalleryState) -> String?

    func descriptionForState(_ state: MediaGalleryState) -> String?

    func imageForState(_ state: MediaGalleryState) -> UIImage?

}

extension MediaGalleryViewModelable {

    public func indexOfPreview(_ preview: MediaPreviewable) -> Int? {
        return previews.index(where: { $0 === preview })
    }

    public func titleForState(_ state: MediaGalleryState) -> String? {
        switch state {
        case .unknown:
            return "Download Images"
        case .loading:
            return "Loading"
        case .completed(let additionalItem):
            return additionalItem ? "Load more" : "Completed"
        case .error:
            return "Error"
        }
    }

    public func descriptionForState(_ state: MediaGalleryState) -> String? {
        switch state {
        case .unknown:
            return "This may take a moment depending on your connection speed."
        case .loading:
            return "Please wait a moment."
        case .completed(let additionalItem):
            return additionalItem ? "This may take a moment depending on your connection speed." : "Completed"
        case .error(let error):
            return error.localizedDescription
        }
    }

    public func imageForState(_ state: MediaGalleryState) -> UIImage? {
        return AssetManager.shared.image(forKey: .sourceBarDownload)
    }

}

public let MediaGalleryDidChangeNotificationName = Notification.Name("MediaGalleryDidChangeNotificationName")


public class MediaGalleryCoordinatorViewModel<T: WritableDataStore>: MediaGalleryViewModelable where T.Result: PaginatedDataStoreResult, T.Result.Item == Media {

    public private(set) var state: MediaGalleryState = .unknown

    public private(set) var previews: [MediaPreviewable] = []

    public let storeCoordinator: DataStoreCoordinator<T>

    /// A registry of controllers for media items
    private var previewControllers: [ObjectIdentifier: (UIViewController & MediaViewPresentable).Type] = [:]

    public init(storeCoordinator: DataStoreCoordinator<T>) {
        self.storeCoordinator = storeCoordinator

        generatePreviews()
        updateState()
        registerDefaultPreviewControllers()

        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange(_:)), name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)

        if storeCoordinator.state == .unknown {
            storeCoordinator.retrieveItems()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)
    }

    open func previewForMedia(_ media: Media) -> MediaPreviewable {
        switch media.type {
        case .photo: return PhotoPreview(asset: media)
        case .audio: return AudioPreview(media: media)
        case .video: return VideoPreview(media: media)
        }
    }

    public func controllerForPreview(_ preview: MediaPreviewable) -> UIViewController? {
        return previewControllers[ObjectIdentifier(type(of: preview))]?.controller(forAsset: preview)
    }

    /// Register a controller type to a specific mediaPreviewable object
    ///
    /// - Parameters:
    ///   - controller: The type of the controller to register
    ///   - asset: The media the controller is to be registered against
    public func register(_ controller: (UIViewController & MediaViewPresentable).Type, for preview: MediaPreviewable.Type) {
        previewControllers[ObjectIdentifier(preview)] = controller
    }

    /// Register default controllers for media items
    private func registerDefaultPreviewControllers() {
        register(AVMediaViewController.self, for: AudioPreview.self)
        register(MediaViewController.self, for: PhotoPreview.self)
        register(AVMediaViewController.self, for: VideoPreview.self)
    }

    @objc private func storeDidChange(_ notification: Notification) {
        generatePreviews()
        updateState()

        NotificationCenter.default.post(name: MediaGalleryDidChangeNotificationName, object: self)
    }

    private func generatePreviews() {
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

    public func addMedia(_ media: [Media]) -> Promise<Bool> {
        return storeCoordinator.addItems(media).then { [weak self] _ -> Promise<[Media]> in
            guard let `self` = self else { return Promise(error: NSError(domain: "abc", code: 101, userInfo: [:]))}
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

    public func removeMedia(_ media: [Media]) -> Promise<Bool> {
        return storeCoordinator.removeItems(media).then { [weak self] _ -> Promise<[Media]> in
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
