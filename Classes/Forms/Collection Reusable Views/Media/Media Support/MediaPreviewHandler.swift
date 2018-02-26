//
//  MediaPreviewHandler.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class MediaPreviewHandler: MediaGalleryDelegate {

    public let allowEditing: Bool

    public let pickerSources: [MediaPickerSource]

    public init(allowEditing: Bool = true, pickerSources: [MediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker(), AudioMediaPicker(), SketchMediaPicker()]) {
        self.allowEditing = allowEditing
        self.pickerSources = pickerSources
    }

    public func previewViewControllerForPreview(_ preview: MediaPreviewable, inGalleryViewModel galleryViewModel: MediaGalleryViewModelable) -> UIViewController? {
        return MediaPreviewViewController(mediaAsset: preview)
    }

    public func viewControllerForGalleryViewModel(_ galleryViewModel: MediaGalleryViewModelable, fromPreviewViewController previewViewController: UIViewController) -> UIViewController? {
        guard let preview = (previewViewController as? MediaPreviewViewController)?.mediaAsset else { return nil }
        
        let galleryViewController = MediaGalleryViewController(viewModel: galleryViewModel, initialPreview: preview, pickerSources: pickerSources)
        galleryViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: galleryViewController)
    }

    public func viewControllerForGalleryViewModel(_ galleryViewModel: MediaGalleryViewModelable) -> UIViewController? {
        let galleryViewController = MediaGalleryViewController(viewModel: galleryViewModel, pickerSources: pickerSources)
        galleryViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: galleryViewController)
    }

    public func mediaItemViewControllerForPreview(_ preview: MediaPreviewable, inGalleryViewModel galleryViewModel: MediaGalleryViewModelable) -> UIViewController? {
        let galleryViewController = MediaGalleryViewController(viewModel: galleryViewModel, initialPreview: preview, pickerSources: pickerSources)
        galleryViewController.allowEditing = allowEditing
        return UINavigationController(rootViewController: galleryViewController)
    }

}
