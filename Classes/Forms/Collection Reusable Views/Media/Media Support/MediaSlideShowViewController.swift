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

    var currentPreview: MediaPreviewable? { get }

    func setupWithInitialPreview(_ preview: MediaPreviewable?)

}

public class MediaSlideShowViewController: UIViewController, MediaSlideShowable, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private var isFullScreen: Bool = false

    // Detects whether the status bar appearance should be based on `UIApplication` or `UIViewController`.
    private lazy var isUIViewControllerBasedStatusBarAppearance: Bool = {
        let infoPlist = Bundle.main.infoDictionary
        if let isViewControllerBased = infoPlist?["UIViewControllerBasedStatusBarAppearance"] as? Bool {
            return isViewControllerBased
        }
        // If not declared, the default value is `true`
        return true
    }()

    private lazy var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])

    public var allowEditing: Bool = true

    public var overlayView: MediaOverlayViewable = MediaSlideShowOverlayView(frame: UIScreen.main.bounds) {
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

    public var currentPreviewViewController: MediaViewController? {
        return pageViewController.viewControllers?.first as? MediaViewController
    }

    public var currentPreview: MediaPreviewable? {
        return currentPreviewViewController?.preview
    }

    public let viewModel: MediaGalleryViewModelable

    public init(viewModel: MediaGalleryViewModelable, initialPreview: MediaPreviewable? = nil, referenceView: UIView? = nil) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        setupWithInitialPreview(initialPreview)

        NotificationCenter.default.addObserver(self, selector: #selector(galleryDidChange), name: MediaGalleryDidChangeNotificationName, object: viewModel)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    public func setupWithInitialPreview(_ preview: MediaPreviewable?) {
        setupWithInitialPreview(preview, animated: false)
    }

    public func setupWithInitialPreview(_ preview: MediaPreviewable?, animated: Bool) {
        // Page controller

        var initialPreview = preview
        if let preview = viewModel.previews.first, initialPreview == nil {
            initialPreview = preview
        }

        if let preview = initialPreview {
            var direction = UIPageViewControllerNavigationDirection.forward
            if let currentPreview = self.currentPreview,
               let currentIndex = indexOfPreview(currentPreview),
               let nextIndex = indexOfPreview(preview), nextIndex < currentIndex {
                direction = .reverse
            }

            guard let mediaViewController = previewViewControllerForPreview(preview) else { return }
            pageViewController.setViewControllers([mediaViewController], direction: direction, animated: animated, completion: nil)
            overlayView.populateWithPreview(preview)
        }
    }

    public func showPreview(_ preview: MediaPreviewable, animated: Bool, direction: UIPageViewControllerNavigationDirection = .forward) {
        guard indexOfPreview(preview) != nil,
        let mediaViewController = previewViewControllerForPreview(preview) else { return }

        pageViewController.setViewControllers([mediaViewController], direction: direction, animated: animated, completion: nil)
        overlayView.populateWithPreview(preview)
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
        guard let previewViewController = viewController as? MediaViewController else { return nil }
        guard let index = indexOfPreview(previewViewController.preview) else { return nil }

        let previousMediaIndex = index - 1
        if previousMediaIndex < 0 {
            return nil
        }

        let newPreview = viewModel.previews[previousMediaIndex]
        return previewViewControllerForPreview(newPreview)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previewViewController = viewController as? MediaViewController else { return nil }
        guard let index = indexOfPreview(previewViewController.preview) else { return nil }

        let nextMediaIndex = index + 1
        if nextMediaIndex >= viewModel.previews.count {
            return nil
        }

        let newPreview = viewModel.previews[nextMediaIndex]
        return previewViewControllerForPreview(newPreview)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentPreview = currentPreview {
                overlayView.populateWithPreview(currentPreview)
            }
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    // MARK: - Photo management

    public func handleDeletePreviewButtonTapped(_ item: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Media", comment: ""), style: .destructive, handler: { (action) in
            self.deleteCurrentPreview()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func previewViewControllerForPreview(_ preview: MediaPreviewable) -> UIViewController? {
        return viewModel.controllerForPreview(preview)
    }

    private func previewAfterDeletion(currentPreviewIndex index: Int) -> MediaPreviewable? {
        if index < viewModel.previews.count {
            return viewModel.previews[index]
        }

        return viewModel.previews[index - 1]
    }

    private func deleteCurrentPreview() {
        guard let currentMedia = currentPreview else { return }

        if let index = indexOfPreview(currentMedia) {
            viewModel.removeMedia([currentMedia.media]).then { [weak self] _ -> () in
                guard let `self` = self else { return }
                if let preview = self.previewAfterDeletion(currentPreviewIndex: index) {
                    self.showPreview(preview, animated: true, direction: index >= self.viewModel.previews.count ? .reverse : .forward)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func indexOfPreview(_ preview: MediaPreviewable) -> Int? {
        return viewModel.previews.index(where: { $0 === preview })
    }

    private func setFullScreen(_ isFullScreen: Bool, animated: Bool = true) {
        self.isFullScreen = isFullScreen
        overlayView.setHidden(isFullScreen, animated: animated)
        if isUIViewControllerBasedStatusBarAppearance {
            setNeedsStatusBarAppearanceUpdate()
        } else {
            let animation: UIStatusBarAnimation = animated ? .slide : .none
            UIApplication.shared.setStatusBarHidden(isFullScreen, with: animation)
        }
    }

    @objc private func galleryDidChange(_ notification: Notification) {
        
    }

    // MARK: - Gesture Recognizers

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        setFullScreen(!isFullScreen, animated: true)
    }

}
