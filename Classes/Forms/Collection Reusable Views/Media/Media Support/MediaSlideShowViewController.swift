//
//  MediaSlideShowViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol MediaSlideShowable: class {

    var viewModel: MediaGalleryViewModelable { get }

    var currentMedia: MediaPreviewable? { get }

    func setupWithInitialMedia(_ media: MediaPreviewable?)

}

public class MediaSlideShowViewController: UIViewController, MediaSlideShowable, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])

    public var allowEditing: Bool = true

    public var overlayView: MediaOverlayViewable = MediaSlideShowOverlayView(frame: .zero) {
        willSet {
            overlayView.view().removeFromSuperview()
        }
        didSet {
            self.overlayView.slideShowViewController = self

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

    public var currentMedia: MediaPreviewable? {
        return currentMediaViewController?.mediaAsset
    }

    public let viewModel: MediaGalleryViewModelable

    public init(viewModel: MediaGalleryViewModelable, initialMedia: MediaPreviewable? = nil, referenceView: UIView? = nil) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        setupWithInitialMedia(initialMedia)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    public func setupWithInitialMedia(_ media: MediaPreviewable?) {
        setupWithInitialMedia(media, animated: false)
    }

    public func setupWithInitialMedia(_ media: MediaPreviewable?, animated: Bool) {
        // Page controller

        var initialMedia = media
        if let preview = viewModel.previews.first, initialMedia == nil {
            initialMedia = preview
        }

        if let media = initialMedia {
            var direction = UIPageViewControllerNavigationDirection.forward
            if let currentMedia = self.currentMedia,
                let currentIndex = indexOfPreview(currentMedia),
                let nextIndex = indexOfPreview(media), nextIndex < currentIndex {
                direction = .reverse
            }

            guard let mediaViewController = mediaViewControllerForPhoto(media) else { return }
            pageViewController.setViewControllers([mediaViewController], direction: direction, animated: animated, completion: nil)
            overlayView.populateWithMedia(media)
        }
    }

    public func showMedia(_ media: MediaPreviewable, animated: Bool, direction: UIPageViewControllerNavigationDirection = .forward) {
        guard indexOfPreview(media) != nil,
        let mediaViewController = mediaViewControllerForPhoto(media) else { return }

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

        self.overlayView.slideShowViewController = self

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
        guard let mediaIndex = indexOfPreview(mediaViewController.mediaAsset) else { return nil }

        let previousMediaIndex = mediaIndex - 1
        if previousMediaIndex < 0 {
            return nil
        }

        let newMedia = viewModel.previews[previousMediaIndex]
        return mediaViewControllerForPhoto(newMedia)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let mediaViewController = viewController as? MediaViewController else { return nil }
        guard let mediaIndex = indexOfPreview(mediaViewController.mediaAsset) else { return nil }

        let nextMediaIndex = mediaIndex + 1
        if nextMediaIndex >= viewModel.previews.count {
            return nil
        }

        let newMedia = viewModel.previews[nextMediaIndex]
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

    private func mediaViewControllerForPhoto(_ media: MediaPreviewable) -> UIViewController? {
        return viewModel.controllerForPreview(media)
    }

    private func mediaAfterDeletion(currentMediaIndex index: Int) -> MediaPreviewable? {
        if index < viewModel.previews.count {
            return viewModel.previews[index]
        }

        return viewModel.previews[index - 1]
    }

    private func deleteCurrentMedia() {
        guard let currentMedia = currentMedia else { return }

        if let index = indexOfPreview(currentMedia) {
            viewModel.removeMedia(currentMedia.asset).then { [weak self] _ -> () in
                guard let `self` = self else { return }
                if let media = self.mediaAfterDeletion(currentMediaIndex: index) {
                    self.showMedia(media, animated: true, direction: index >= self.viewModel.previews.count ? .reverse : .forward)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func indexOfPreview(_ preview: MediaPreviewable) -> Int? {
        return viewModel.previews.index(where: { $0 === preview })
    }

    // MARK: - Gesture Recognizers

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        overlayView.setHidden(!overlayView.view().isHidden, animated: true)
    }

}
