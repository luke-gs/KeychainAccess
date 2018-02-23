//
//  MediaPreviewHandler.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class MediaPreviewHandler<T: WritableDataStore>: MediaPreviewableDelegate, MediaPreviewCollectionDataSource where T.Result: PaginatedDataStoreResult, T.Result.Item: Media {

    public let storeCoordinator: DataStoreCoordinator<T>

    public let galleryViewModel: MediaGalleryViewModel

    public var allowEditing: Bool

    public var pickerSources: [MediaPickerSource]

    public init(storeCoordinator: DataStoreCoordinator<T>, allowEditing: Bool = true, pickerSources: [MediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker(), AudioMediaPicker(), SketchMediaPicker()]) {
        self.storeCoordinator = storeCoordinator
        self.allowEditing = allowEditing
        self.pickerSources = pickerSources

        if storeCoordinator.state == .unknown {
            _ = storeCoordinator.retrieveItems()
        }

        galleryViewModel = MediaGalleryViewModel()

        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange), name: DataStoreCoordinatorDidChangeStateNotification, object: storeCoordinator)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification

    @objc private func storeDidChange() {
        NotificationCenter.default.post(name: MediaPreviewCollectionDataSourceDidChange, object: self)
    }

    // MARK: - DataSource

    public func numberOfMediaPreviews() -> Int {
        return storeCoordinator.items.count
    }

    public func previewAtIndex(_ index: Int) -> MediaPreviewable {
        let item = storeCoordinator.items[index]
        return MediaPreview(thumbnailImage: AssetManager.shared.image(forKey: .info), asset: item)
    }


    // MARK: - Delegate

    public func previewViewControllerForMediaItem(_ mediaItem: MediaPreviewable) -> UIViewController? {
        return MediaPreviewViewController(mediaAsset: mediaItem)
    }

    public func viewControllerForMediaDataSource(fromPreviewViewController previewViewController: UIViewController) -> UIViewController? {
        guard let mediaAsset = (previewViewController as? MediaPreviewViewController)?.mediaAsset else { return nil }

        let mediaViewController = MediaGalleryViewController(viewModel: galleryViewModel, storeCoordinator: storeCoordinator, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func viewControllerForMediaDataSource() -> UIViewController? {
        let mediaViewController = MediaGalleryViewController(viewModel: galleryViewModel, storeCoordinator: storeCoordinator, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func mediaItemViewControllerForMediaItem(_ mediaItem: MediaPreviewable) -> UIViewController? {
        let mediaViewController = MediaGalleryViewController(viewModel: galleryViewModel, storeCoordinator: storeCoordinator, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }



}
