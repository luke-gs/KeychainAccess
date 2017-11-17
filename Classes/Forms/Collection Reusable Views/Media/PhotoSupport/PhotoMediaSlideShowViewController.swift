//
//  PhotoMediaSlideShowViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class PhotoMediaSlideShowViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])

    public let dataSource: MediaDataSource<PhotoMedia>

    public var allowEditing: Bool = true

    public var overlayView: PhotoMediaOverlayViewable = PhotoMediaSlideShowOverlayView(frame: .zero) {
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
        return UITapGestureRecognizer(target: self, action: #selector(PhotoMediaSlideShowViewController.handleTapGestureRecognizer(_:)))
    }()

    public var currentMediaViewController: PhotoMediaViewController? {
        return pageViewController.viewControllers?.first as? PhotoMediaViewController
    }

    public var currentPhotoMedia: PhotoMedia? {
        return currentMediaViewController?.photoMedia
    }

    public init(dataSource: MediaDataSource<PhotoMedia>, initialPhotoMedia: PhotoMedia? = nil, referenceView: UIView? = nil) {
        self.dataSource = dataSource

        super.init(nibName: nil, bundle: nil)

        setupWithInitialPhoto(initialPhotoMedia)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    public func setupWithInitialPhoto(_ photo: PhotoMedia?, animated: Bool = false) {
        // Page controller
        if let photo = photo ?? dataSource.mediaItemAtIndex(0) {
            var direction = UIPageViewControllerNavigationDirection.forward
            if let currentPhoto = self.currentPhotoMedia,
                let currentIndex = dataSource.indexOfMediaItem(currentPhoto),
                let nextIndex = dataSource.indexOfMediaItem(photo), nextIndex < currentIndex {
                direction = .reverse
            }

            let photoViewController = photoViewControllerForPhoto(photo)
            pageViewController.setViewControllers([photoViewController], direction: direction, animated: animated, completion: nil)
            overlayView.populateWithPhoto(photo)
        }
    }

    public func showPhoto(_ photo: PhotoMedia, animated: Bool, direction: UIPageViewControllerNavigationDirection = .forward) {
        guard dataSource.indexOfMediaItem(photo) != nil else { return }

        let photoViewController = photoViewControllerForPhoto(photo)
        pageViewController.setViewControllers([photoViewController], direction: direction, animated: animated, completion: nil)
        overlayView.populateWithPhoto(photo)
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
        guard let mediaViewController = viewController as? PhotoMediaViewController,
            let photoIndex = dataSource.indexOfMediaItem(mediaViewController.photoMedia),
            let newPhoto = dataSource[photoIndex - 1] else { return nil }
        return photoViewControllerForPhoto(newPhoto)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let mediaViewController = viewController as? PhotoMediaViewController,
            let photoIndex = dataSource.indexOfMediaItem(mediaViewController.photoMedia),
            let newPhoto = dataSource[photoIndex + 1] else { return nil }
        return photoViewControllerForPhoto(newPhoto)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentPhotoMedia = currentPhotoMedia {
                overlayView.populateWithPhoto(currentPhotoMedia)
            }
        }
    }

    // MARK: - Photo management

    public func handleDeletePhotoButtonTapped(_ item: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Photo", comment: ""), style: .destructive, handler: { (action) in
            self.deleteCurrentPhoto()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func photoViewControllerForPhoto(_ photo: PhotoMedia) -> UIViewController {
        let mediaViewController = PhotoMediaViewController(photoMedia: photo)
        return mediaViewController
    }

    private func photoAfterDeletion(currentPhotoIndex index: Int) -> PhotoMedia? {
        if let photo = dataSource.mediaItemAtIndex(index) {
            return photo
        }

        return dataSource.mediaItemAtIndex(index - 1)
    }

    private func deleteCurrentPhoto() {
        guard let currentPhotoMedia = currentPhotoMedia else { return }

        if let index = dataSource.indexOfMediaItem(currentPhotoMedia) {
            dataSource.removeMediaItem(currentPhotoMedia)
            if let photo = photoAfterDeletion(currentPhotoIndex: index) {
                showPhoto(photo, animated: true, direction: index == dataSource.numberOfMediaItems() ? .reverse : .forward)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Gesture Recognizers

    public weak var mediaOverviewViewController: PhotoMediaGalleryViewController?

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        overlayView.setHidden(!overlayView.view().isHidden, animated: true)
    }

}
