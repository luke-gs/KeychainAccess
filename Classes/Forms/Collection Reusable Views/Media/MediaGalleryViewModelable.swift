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
    case noContents
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

}

public let MediaGalleryDidChangeNotificationName = Notification.Name("MediaGalleryDidChangeNotificationName")


open class MediaGalleryCoordinatorViewModel<T: WritableDataStore>: MediaGalleryViewModelable where T.Result: PaginatedDataStoreResult, T.Result.Item: Media {

    public private(set) var state: MediaGalleryState = .unknown

    public private(set) var previews: [MediaPreviewable] = []

    public let storeCoordinator: DataStoreCoordinator<T>
    
    public var filterDescriptors: [FilterDescriptor<T.Result.Item>]? {
        didSet {
            reload()
        }
    }
    
    public var sortDescriptors: [SortDescriptor<T.Result.Item>]? {
        didSet {
            reload()
        }
    }
    
    /// A registry of controllers for media items
    private var previewControllers: [ObjectIdentifier: (UIViewController & MediaViewPresentable).Type] = [:]

    public init(storeCoordinator: DataStoreCoordinator<T>) {
        self.storeCoordinator = storeCoordinator
        
        reload(notify: false)
        registerDefaultPreviewControllers()

        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange(_:)), name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)

        if storeCoordinator.state == .unknown {
            _ = storeCoordinator.retrieveItems()
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
        return previewControllers[ObjectIdentifier(type(of: preview))]?.controller(forPreview: preview)
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
        reload()
    }
    
    private func reload(notify: Bool = true) {
        generatePreviews()
        updateState()
        
        if notify {
            NotificationCenter.default.post(name: MediaGalleryDidChangeNotificationName, object: self)
        }
    }

    private func generatePreviews() {
        var items: [T.Result.Item] = storeCoordinator.items
        
        if let filterDescriptors = filterDescriptors {
            items = items.filter(using: filterDescriptors)
        }
        
        if let sortDescriptors = sortDescriptors {
            items = items.sorted(using: sortDescriptors)
        }
        
        previews = items.map { self.previewForMedia($0) }
    }
    
    private func updateState() {
        switch storeCoordinator.state {
        case .unknown:
            state = .unknown
        case .completed:
            if previews.count == 0 && storeCoordinator.items.count > 0 {
                state = .noContents
            } else {
                state = .completed(hasAdditionalItems: storeCoordinator.hasMoreItems())
            }
        case .loading:
            state = .loading
        case .error(let error):
            state = .error(error)
        }
    }

    open func titleForState(_ state: MediaGalleryState) -> String? {
        switch state {
        case .unknown:
            return NSLocalizedString("GalleryStateUnknownTitle", value: "Download Images", comment: "Initial state of gallery view model")
        case .loading:
            return NSLocalizedString("GalleryStateLoadingTitle", value: "Loading", comment: "Loading state of gallery view model")
        case .completed(let additionalItem):
            if additionalItem {
                return NSLocalizedString("GalleryStateCompletedWithMoreItemTitle", value: "Load more", comment: "Completed with more items state of gallery view model")
            } else {
                return NSLocalizedString("GalleryStateCompletedTitle", value: "Completed", comment: "Completed state of gallery view model")
            }
        case .error:
            return NSLocalizedString("GalleryStateErrorTitle", value: "Error", comment: "Error state of gallery view model")
        case .noContents:
            if previews.count == 0 && storeCoordinator.items.count > 0 {
                return NSLocalizedString("GalleryStateNoContentsFilteredTitle", value: "No Assets", comment: "No Contents state of gallery view model")
            } else {
                return NSLocalizedString("GalleryStateNoContentsTitle", value: "No Assets", comment: "No Contents state of gallery view model")
            }
        }
    }
    
    open func descriptionForState(_ state: MediaGalleryState) -> String? {
        switch state {
        case .unknown:
            return NSLocalizedString("GalleryStateUnknownDescription", value: "This may take a moment depending on your connection speed.", comment: "Initial state of gallery view model")
        case .loading:
            return NSLocalizedString("GalleryStateLoadingDescription", value: "Please wait a moment.", comment: "Loading state of gallery view model")
        case .completed(let additionalItem):
            if additionalItem {
                return NSLocalizedString("GalleryStateCompletedWithMoreItemDescription", value: "This may take a moment depending on your connection speed.", comment: "Completed with more items state of gallery view model")
            } else {
                return NSLocalizedString("GalleryStateCompletedDescription", value: "Completed", comment: "Completed state of gallery view model")
            }
        case .error(let error):
            return NSLocalizedString("GalleryStateErrorDescription", value: error.localizedDescription, comment: "Error state of gallery view model")
        case .noContents:
            if previews.count == 0 && storeCoordinator.items.count > 0 {
                return NSLocalizedString("GalleryStateNoContentsFilteredDescription", value: "Please update your filters.", comment: "No Contents state of gallery view model")
            } else {
                return NSLocalizedString("GalleryStateNoContentsDescription", value: "No Assets Found.", comment: "No Contents state of gallery view model")
            }
        }
    }
    
    open func imageForState(_ state: MediaGalleryState) -> UIImage? {
        return AssetManager.shared.image(forKey: .download)
    }
    
    // MARK: - Previews Retrieval

    public func retrievePreviews(style: MediaGalleryRetrieveStyle) {
        switch style {
        case .reset:
            _ = storeCoordinator.retrieveItems()
        case .paginated:
            _ = storeCoordinator.retrieveMoreItems()
        }
    }

    public func addMedia(_ media: [Media]) -> Promise<Bool> {
        guard let media = media as? [T.Result.Item] else {
            return Promise(error: MediaGalleryCoordinatorViewModelError.unsupportedMedia)
        }
        
        return storeCoordinator.addItems(media).then { [weak self] _ -> Promise<[T.Result.Item]> in
            guard let `self` = self else { return Promise(error: NSError.cancelledError()) }
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

    public func removeMedia(_ media: [Media]) -> Promise<Bool> {
        guard let media = media as? [T.Result.Item] else {
            return Promise(error: MediaGalleryCoordinatorViewModelError.unsupportedMedia)
        }
        
        return storeCoordinator.removeItems(media).then { [weak self] _ -> Promise<[T.Result.Item]> in
            guard let `self` = self else { return Promise(error: NSError.cancelledError()) }
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

    public func replaceMedia(_ media: Media, with otherMedia: Media) -> Promise<Bool> {
        guard let media = media as? T.Result.Item, let otherMedia = otherMedia as? T.Result.Item else {
            return Promise(error: MediaGalleryCoordinatorViewModelError.unsupportedMedia)
        }
        
        return storeCoordinator.replaceItem(media, with: otherMedia).then { [weak self] _ -> Promise<[T.Result.Item]> in
            guard let `self` = self else { return Promise(error: NSError.cancelledError()) }
            return self.storeCoordinator.retrieveItems()
        }.then { _ -> Bool in
            return true
        }
    }

}

public enum MediaGalleryCoordinatorViewModelError: Error {
    case unsupportedMedia
}
