//
//  MediaSlideShowViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class MediaSlideShowViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])

    public let dataSource: MediaDataSource<MediaAsset>

    public var allowEditing: Bool = true

    public var overlayView: MediaOverlayViewable = MediaSlideShowOverlayView(frame: .zero) {
        willSet {
            overlayView.view().removeFromSuperview()
        }
        didSet {
            self.overlayView.galleryViewController = self

            guard isViewLoaded else { return }
            let overlayView = self.overlayView.view()
            overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlayView.frame = view.bounds
        }
    }

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(MediaSlideShowViewController.handleTapGestureRecognizer(_:)))
    }()

    public var currentMediaViewController: MediaViewController? {
        return pageViewController.viewControllers?.first as? MediaViewController
    }

    public var currentMedia: MediaAsset? {
        return currentMediaViewController?.mediaAsset
    }

    public init(dataSource: MediaDataSource<MediaAsset>, initialMedia: MediaAsset? = nil, referenceView: UIView? = nil) {
        self.dataSource = dataSource

        super.init(nibName: nil, bundle: nil)

        setupWithInitialMedia(initialMedia)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - Setup

    public func setupWithInitialMedia(_ media: MediaAsset?, animated: Bool = false) {
        // Page controller
        if let media = media ?? dataSource.mediaItemAtIndex(0) {
            var direction = UIPageViewControllerNavigationDirection.forward
            if let currentMedia = self.currentMedia,
                let currentIndex = dataSource.indexOfMediaItem(currentMedia),
                let nextIndex = dataSource.indexOfMediaItem(media), nextIndex < currentIndex {
                direction = .reverse
            }

            let mediaViewController = mediaViewControllerForPhoto(media)
            pageViewController.setViewControllers([mediaViewController], direction: direction, animated: animated, completion: nil)
            overlayView.populateWithMedia(media)
        }
    }

    public func showMedia(_ media: MediaAsset, animated: Bool, direction: UIPageViewControllerNavigationDirection = .forward) {
        guard dataSource.indexOfMediaItem(media) != nil else { return }

        let mediaViewController = mediaViewControllerForPhoto(media)
        pageViewController.setViewControllers([mediaViewController], direction: direction, animated: animated, completion: nil)
        overlayView.populateWithMedia(media)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = .white

        // Add page controller
        addChildViewController(pageViewController)
        pageViewController.view.backgroundColor = .clear
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.addGestureRecognizer(tapGestureRecognizer)

        self.overlayView.galleryViewController = self

        pageViewController.delegate = self
        pageViewController.dataSource = self
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let overlayView = self.overlayView.view()
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.frame = self.view.bounds
        if #available(iOS 11.0, *) {
            overlayView.layoutMargins = view.safeAreaInsets
        } else {
            overlayView.layoutMargins = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        }
        self.view.addSubview(overlayView)
    }

    // MARK: - PageViewControllerDelegate / PageViewControllerDataSource

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let mediaViewController = viewController as? MediaViewController else { return nil }
        guard let mediaIndex = dataSource.indexOfMediaItem(mediaViewController.mediaAsset) else { return nil }
        guard let newMedia = dataSource[mediaIndex - 1] else { return nil }
        return mediaViewControllerForPhoto(newMedia)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let mediaViewController = viewController as? MediaViewController else { return nil }
        guard let mediaIndex = dataSource.indexOfMediaItem(mediaViewController.mediaAsset) else { return nil }
        guard let newMedia = dataSource[mediaIndex + 1] else { return nil }
        return mediaViewControllerForPhoto(newMedia)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentMedia = currentMedia {
                overlayView.populateWithMedia(currentMedia)
            }
        }
    }

    // MARK: - Photo management

    public func handleDeleteMediaButtonTapped(_ item: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Media", comment: ""), style: .destructive, handler: { (action) in
            self.deleteCurrentMedia()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func mediaViewControllerForPhoto(_ media: MediaAsset) -> UIViewController {
        return dataSource.viewController(for: media)
    }

    private func mediaAfterDeletion(currentMediaIndex index: Int) -> MediaAsset? {
        if let photo = dataSource.mediaItemAtIndex(index) {
            return photo
        }

        return dataSource.mediaItemAtIndex(index - 1)
    }

    private func deleteCurrentMedia() {
        guard let currentMedia = currentMedia else { return }

        if let index = dataSource.indexOfMediaItem(currentMedia) {
            dataSource.removeMediaItem(currentMedia)
            if let media = mediaAfterDeletion(currentMediaIndex: index) {
                showMedia(media, animated: true, direction: index == dataSource.numberOfMediaItems() ? .reverse : .forward)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Gesture Recognizers

    public weak var mediaOverviewViewController: MediaGalleryViewController?

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        overlayView.setHidden(!overlayView.view().isHidden, animated: true)
    }

}
