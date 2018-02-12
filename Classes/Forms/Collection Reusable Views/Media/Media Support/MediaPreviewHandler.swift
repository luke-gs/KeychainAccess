//
//  MediaPreviewHandler.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class MediaPreviewHandler: MediaPreviewableDelegate {

    public typealias Media = MediaAsset

    public var allowEditing: Bool

    public var pickerSources: [MediaPickerSource]

    public init(allowEditing: Bool = true, pickerSources: [MediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker(), AudioMediaPicker(), SketchMediaPicker()]) {
        self.allowEditing = allowEditing
        self.pickerSources = pickerSources
    }

    public func previewViewControllerForMediaItem(_ mediaItem: MediaAsset, inDataSource dataSource: MediaDataSource<MediaAsset>) -> UIViewController? {
        return MediaPreviewViewController(mediaAsset: mediaItem)
    }

    public func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<MediaAsset>, fromPreviewViewController previewViewController: UIViewController) -> UIViewController? {
        guard let mediaAsset = (previewViewController as? MediaPreviewViewController)?.mediaAsset else { return nil }
        let mediaViewController = MediaGalleryViewController(dataSource: dataSource, initialAsset: mediaAsset, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func mediaItemViewControllerForMediaItem(_ mediaItem: MediaAsset, inDataSource dataSource: MediaDataSource<MediaAsset>) -> UIViewController? {
        let mediaViewController = MediaGalleryViewController(dataSource: dataSource, initialAsset: mediaItem, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<MediaAsset>) -> UIViewController? {
        let mediaViewController = MediaGalleryViewController(dataSource: dataSource, initialAsset: nil, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

}
