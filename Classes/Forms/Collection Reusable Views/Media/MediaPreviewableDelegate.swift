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
public protocol MediaPreviewableDelegate: class {

    associatedtype Media: MediaPreviewable

    /// Returns a view controller to be used as a preview controller.
    /// This only works on devices with force touch. (E.g. iPhone 7 and above).
    ///
    /// - Parameters:
    ///   - mediaItem: The media item that has been force touched.
    ///   - dataSource: The data source of the media item.
    /// - Returns: A view controller to be presented as a preview.
    func previewViewControllerForMediaItem(_ mediaItem: Media, inDataSource dataSource: MediaDataSource<Media>) -> UIViewController?

    /// Returns a view controller to be used once a preview controller is commited.
    /// This only works on devices with fource touch. (E.g. iPhone 7 and above).
    ///
    /// - Parameters:
    ///   - dataSource: The data source of the media item
    ///   - previewViewController: The preview controller
    /// - Returns: A view controller to be presented.
    func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<Media>, fromPreviewViewController previewViewController: UIViewController) -> UIViewController?

    /// Returns a view controller to be used when a media item is selected.
    ///
    /// - Parameters:
    ///   - mediaItem: The media item that has been selected.
    ///   - dataSource: The data source of the media item.
    /// - Returns: A view controller to be presented.
    func mediaItemViewControllerForMediaItem(_ mediaItem: Media, inDataSource dataSource: MediaDataSource<Media>) -> UIViewController?

    /// Returns a view controller to be used when the action button is selected.
    /// A potential use case is when there are no media items.
    ///
    /// - Parameter dataSource: The data source
    /// - Returns: A view controller to be presented.
    func viewControllerForMediaDataSource(_ dataSource: MediaDataSource<Media>) -> UIViewController?

}
