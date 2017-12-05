//
//  PhotoMediaPreviewHandler.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class PhotoMediaPreviewHandler: MediaPreviewableDelegate {

    public typealias Media = PhotoMedia

    public var allowEditing: Bool

    public var pickerSources: [PhotoMediaPickerSource]

    public init(allowEditing: Bool = true, pickerSources: [PhotoMediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker()]) {
        self.allowEditing = allowEditing
        self.pickerSources = pickerSources
    }

    public func previewViewControllerForMediaItem(_ mediaItem: PhotoMedia, inDataSource dataSource: MediaDataSource<PhotoMedia>) -> UIViewController? {
        return PhotoMediaPreviewViewController(photoMedia: mediaItem)
    }

    public func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<PhotoMedia>, fromPreviewViewController previewViewController: UIViewController) -> UIViewController? {
        guard let photoMedia = (previewViewController as? PhotoMediaPreviewViewController)?.photoMedia else { return nil }
        let mediaViewController = PhotoMediaGalleryViewController(dataSource: dataSource, initialPhoto: photoMedia, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func mediaItemViewControllerForMediaItem(_ mediaItem: PhotoMedia, inDataSource dataSource: MediaDataSource<PhotoMedia>) -> UIViewController? {
        let mediaViewController = PhotoMediaGalleryViewController(dataSource: dataSource, initialPhoto: mediaItem, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

    public func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<PhotoMedia>) -> UIViewController? {
        let mediaViewController = PhotoMediaGalleryViewController(dataSource: dataSource, initialPhoto: nil, pickerSources: pickerSources)
        mediaViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: mediaViewController)
    }

}
