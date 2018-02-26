//
//  MediaPreviewableDelegate.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A `CollectionViewFormMediaCell`'s delegate protocol.
///
/// Implement this protocol to provide custom behaviours on selection of media item in the `CollectionViewFormMediaCell`.
public protocol MediaGalleryDelegate: class {

    // MARK: - Controllers creation

    /// Returns a view controller to be used as a preview controller.
    /// This only works on devices with force touch. (E.g. iPhone 7 and above).
    ///
    /// - Parameters:
    ///   - preview: The preview item that has been force touched.
    ///   - galleryViewModel: The gallery of the preview item.
    /// - Returns: A view controller to be presented as a preview.
    func previewViewControllerForPreview(_ preview: MediaPreviewable, inGalleryViewModel galleryViewModel: MediaGalleryViewModelable) -> UIViewController?

    /// Returns a view controller to be used once a preview controller is commited.
    /// This only works on devices with fource touch. (E.g. iPhone 7 and above).
    ///
    /// - Parameters:
    ///   - galleryViewModel: The gallery of the preview item
    ///   - previewViewController: The preview controller
    /// - Returns: A view controller to be presented.
    func viewControllerForGalleryViewModel(_ galleryViewModel: MediaGalleryViewModelable, fromPreviewViewController previewViewController: UIViewController) -> UIViewController?

    /// Returns a view controller to be used when a media item is selected.
    ///
    /// - Parameters:
    ///   - preview: The preview item that has been selected.
    ///   - galleryViewModel: The gallery of the preview item.
    /// - Returns: A view controller to be presented.
    func mediaItemViewControllerForPreview(_ preview: MediaPreviewable, inGalleryViewModel galleryViewModel: MediaGalleryViewModelable) -> UIViewController?

    /// Returns a view controller to be used when the action button is selected.
    /// A potential use case is when there are no media items.
    ///
    /// - Parameter galleryViewModel: The gallery view model
    /// - Returns: A view controller to be presented.
    func viewControllerForGalleryViewModel(_ galleryViewModel: MediaGalleryViewModelable) -> UIViewController?

}
