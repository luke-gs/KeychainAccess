//
//  MediaSlideShowViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol MediaSlideShowable: class {

    var viewModel: MediaGalleryViewModelable { get }

    var currentPreview: MediaPreviewable? { get }

}

public let MediaSlideshowHideShowDuration = UINavigationControllerHideShowBarDuration

public class MediaSlideShowViewController: UIViewController, MediaSlideShowable, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, MediaThumbnailSlideshowViewControllerDelegate {

    private enum Identifier: String {
        case genericCell
        case stateCell
    }
    
    private var isFullScreen: Bool = false

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

    public var currentPreviewViewController: MediaViewController?

    public var currentPreview: MediaPreviewable? { return currentPreviewViewController?.preview }

    public let viewModel: MediaGalleryViewModelable

    public let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var initialPreview: MediaPreviewable?

    private lazy var thumbnailSlideshowViewController: MediaThumbnailSlideshowViewController = {
        let thumbnailSlideShowViewController = MediaThumbnailSlideshowViewController(viewModel: self.viewModel)
        thumbnailSlideShowViewController.delegate = self
        return thumbnailSlideShowViewController
    }()

    public init(viewModel: MediaGalleryViewModelable, initialPreview: MediaPreviewable? = nil, referenceView: UIView? = nil) {
        self.viewModel = viewModel
        self.initialPreview = initialPreview

        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(galleryDidChange), name: MediaGalleryDidChangeNotificationName, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)

        if let preview = initialPreview {
            currentPreviewViewController = previewViewControllerForPreview(preview)
            currentPreviewViewController?.loadViewIfNeeded()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    public func showPreview(_ preview: MediaPreviewable?, animated: Bool) {
        if let preview = preview {
            scrollToPreview(preview, animated: animated)
        }

        updateCurrentPreviewViewController()
        updateAccessoryViewsWithPreview(preview, animated: animated)
    }

    public func scrollToPreview(_ preview: MediaPreviewable, animated: Bool) {
        guard let index = indexOfPreview(preview), isViewLoaded else { return }

        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }

    public func updateAccessoryViewsWithPreview(_ preview: MediaPreviewable?, animated: Bool) {
        overlayView.populateWithPreview(preview)

        guard let preview = preview, let index = indexOfPreview(preview), isViewLoaded else { return }

        thumbnailSlideshowViewController.setFocusedIndex(index, animated: animated)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true

        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ControllerCell.self, forCellWithReuseIdentifier: Identifier.genericCell.rawValue)
        collectionView.register(MediaStateCell.self, forCellWithReuseIdentifier: Identifier.stateCell.rawValue)
        view.addSubview(collectionView)

        collectionView.addGestureRecognizer(tapGestureRecognizer)
        self.overlayView.slideShowViewController = self

        setupThumbnailSlideShow()
        interfaceStyleDidChange()

        if let preview = viewModel.previews.first, initialPreview == nil {
            initialPreview = preview
        }

        if let preview = initialPreview {
            scrollToPreview(preview, animated: false)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let overlayView = self.overlayView.view()
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.frame = self.view.bounds

        view.insertSubview(overlayView, belowSubview: thumbnailSlideshowViewController.view)

        updateCurrentPreviewViewController()

        if let preview = initialPreview {
            updateAccessoryViewsWithPreview(preview, animated: false)
            initialPreview = nil
        }

        setOverlayEnabled(true, animated: false)
        setThumbnailSlideshowEnabled(true, animated: false)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)

        let preview = currentPreview

        collectionView.alpha = 0.0
        coordinator.animate(alongsideTransition: { _ in
            self.setThumbnailSlideshowEnabled(!self.isFullScreen, animated: false)
        }) { _ in
            self.collectionView.alpha = 1.0
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()

            if let preview = preview {
                self.scrollToPreview(preview, animated: false)
            }
        }

        if let preview = preview, let temporaryViewController = viewModel.controllerForPreview(preview), let previewView = temporaryViewController.view {
            addChildViewController(temporaryViewController)
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.frame = view.bounds
            view.insertSubview(previewView, belowSubview: overlayView.view())
            temporaryViewController.didMove(toParentViewController: self)

            coordinator.animate(alongsideTransition: nil, completion: { _ in
                temporaryViewController.willMove(toParentViewController: nil)
                temporaryViewController.view.removeFromSuperview()
                temporaryViewController.removeFromParentViewController()
            })
        }
    }

    // MARK: - UICollectionViewDelegate / DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch viewModel.state {
        case .completed(let hasAdditionalItems): return hasAdditionalItems ? 2 : 1
        case .unknown: return 2
        case .loading: return 2
        case .error: return 2
        case .noContents: return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? viewModel.previews.count : 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.genericCell.rawValue, for: indexPath) as! ControllerCell
            return cell
        } else {
            let state = viewModel.state
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.stateCell.rawValue, for: indexPath) as! MediaStateCell
            
            let button = cell.button
            let actions = button.actions(forTarget: self, forControlEvent: .touchUpInside)
            if actions == nil || actions?.count == 0 {
                button.setImage(viewModel.imageForState(state), for: .normal)
                button.addTarget(self, action: #selector(actionButtonTouched(_:)), for: .touchUpInside)
            }
            
            cell.titleLabel.text = viewModel.titleForState(state)
            cell.subtitleLabel.text = viewModel.descriptionForState(state)
            
            switch state {
            case .loading: cell.isLoading = true
            default: cell.isLoading = false
            }
            
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ControllerCell {
            let preview = viewModel.previews[indexPath.item]
            
            if let previewController = previewViewControllerForPreview(preview) {
                let contentView = cell.contentView
                
                if let previewView = previewController.view {
                    addChildViewController(previewController)
                    previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    previewView.frame = contentView.bounds
                    contentView.addSubview(previewView)
                    previewController.didMove(toParentViewController: self)
                    cell.viewController = previewController
                }
            }
        } else if let cell = cell as? MediaStateCell {
            cell.apply(theme: ThemeManager.shared.theme(for: .current))
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ControllerCell else { return }

        if let previewController = cell.viewController {
            previewController.willMove(toParentViewController: nil)
            previewController.view.removeFromSuperview()
            previewController.removeFromParentViewController()

            controllerPool[previewController.preview.media] = nil
        }

        cell.viewController = nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPreviewViewController()

        overlayView.populateWithPreview(currentPreview)

        if let currentPreview = currentPreview, let index = indexOfPreview(currentPreview) {
            thumbnailSlideshowViewController.setFocusedIndex(index, animated: true)
        }
    }

    // MARK: - Status bar

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

    private var controllerPool = [MediaAsset: MediaViewController]()

    private func updateCurrentPreviewViewController() {
        let width = collectionView.frame.width
        if width > 0.0, collectionView.contentOffset.x >= 0.0 {
            let index = Int((collectionView.contentOffset.x / width).rounded(.toNearestOrAwayFromZero))
            if index >= viewModel.previews.count {
                currentPreviewViewController = nil
            } else {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                    currentPreviewViewController = (cell as? ControllerCell)?.viewController
                } else {
                    currentPreviewViewController = previewViewControllerForPreview(viewModel.previews[index])
                }
            }
        }
    }

    private func previewViewControllerForPreview(_ preview: MediaPreviewable) -> MediaViewController? {
        var controller: MediaViewController?

        controller = controllerPool[preview.media]

        if controller == nil {
            controller = viewModel.controllerForPreview(preview) as? MediaViewController
            controllerPool[preview.media] = controller
        }

        return controller
    }

    private func previewAfterDeletion(currentPreviewIndex index: Int) -> MediaPreviewable? {
        let numberOfPreviews = viewModel.previews.count
        guard numberOfPreviews > 0 else {
            return nil
        }

        if index < numberOfPreviews {
            return viewModel.previews[index]
        }

        let moveBackwardIndex = index - 1
        return viewModel.previews[moveBackwardIndex]
    }

    private func deleteCurrentPreview() {
        guard let currentPreview = currentPreview else { return }

        if let index = indexOfPreview(currentPreview) {
            _ = viewModel.removeMedia([currentPreview.media]).done { [weak self] _ -> () in
                guard let `self` = self else { return }
                if let preview = self.previewAfterDeletion(currentPreviewIndex: index) {
                    self.showPreview(preview, animated: true)
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

        let enabled = !isFullScreen

        setOverlayEnabled(enabled, animated: animated)
        setThumbnailSlideshowEnabled(enabled, animated: animated)
        setNavigationBarEnabled(enabled, animated: animated)
        setLightModeEnabled(enabled, animated: animated)
    }

    private func setLightModeEnabled(_ enabled: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? TimeInterval(MediaSlideshowHideShowDuration) : 0.0) {
            self.collectionView.backgroundColor = enabled ? self.view.backgroundColor : .black
        }
    }

    private func setOverlayEnabled(_ enabled: Bool, animated: Bool) {
        let thumbnailSliderView = thumbnailSlideshowViewController.view!

        let overlayView = self.overlayView.view()
        if #available(iOS 11.0, *) {
            var insets = self.view.safeAreaInsets
            insets.bottom += (!isFullScreen ? thumbnailSliderView.bounds.height : 0.0)
            overlayView.layoutMargins = insets
        } else {
            overlayView.layoutMargins = UIEdgeInsets(top: self.topLayoutGuide.length,
                                                     left: 0.0,
                                                     bottom: self.bottomLayoutGuide.length + (!isFullScreen ? thumbnailSliderView.bounds.height : 0.0),
                                                     right: 0.0)
        }

        self.overlayView.setHidden(!enabled, animated: animated)
    }

    private func setThumbnailSlideshowEnabled(_ enabled: Bool, animated: Bool) {
        let thumbnailSliderView = thumbnailSlideshowViewController.view!

        UIView.animate(withDuration: animated ? TimeInterval(MediaSlideshowHideShowDuration) : 0.0) {
            var frame = thumbnailSliderView.frame

            if enabled {
                frame.origin = CGPoint(x: 0.0, y: self.view.bounds.height - frame.height)
            } else {
                frame.origin = CGPoint(x: 0.0, y: self.view.bounds.height)
            }

            thumbnailSliderView.frame = frame
        }
    }

    private func setNavigationBarEnabled(_ enabled: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? TimeInterval(MediaSlideshowHideShowDuration) : 0.0, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        self.navigationController?.setNavigationBarHidden(!enabled, animated: animated)
    }

    @objc private func galleryDidChange(_ notification: Notification) {
        guard isViewLoaded else { return }
        collectionView.reloadData()

        // TODO: Workaround in the meantime.
        // There is out of order execution issues.
        // CollectionView reload not completed yet by the time the below is executed.
        // Causing items count to go out of sync and crash.
        DispatchQueue.main.async {
            self.updateCurrentPreviewViewController()
            self.showPreview(self.currentPreview, animated: true)
        }
    }

    private func setupThumbnailSlideShow() {
        // Add thumbnail controller
        addChildViewController(thumbnailSlideshowViewController)

        let thumbnailSlideshowView = thumbnailSlideshowViewController.view!
        thumbnailSlideshowView.autoresizingMask = [.flexibleWidth]
        thumbnailSlideshowView.frame = CGRect(x: 0, y: view.bounds.height - 60.0, width: view.bounds.width, height: 60.0)
        view.addSubview(thumbnailSlideshowView)

        thumbnailSlideshowViewController.didMove(toParentViewController: self)

        setThumbnailSlideshowEnabled(false, animated: false)
    }

    // MARK: - Gesture Recognizers

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        setFullScreen(!isFullScreen, animated: true)
    }

    @objc private func interfaceStyleDidChange() {
        guard isViewLoaded else { return }

        let theme = ThemeManager.shared.theme(for: .current)
        let backgroundColor = theme.color(forKey: .background)
        
        view.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        setLightModeEnabled(!isFullScreen, animated: false)
    }
    
    // MARK: - Interaction
    
    @objc private func actionButtonTouched(_ button: UIButton) {
        if case .loading = viewModel.state {} else {
            viewModel.retrievePreviews(style: .paginated)
        }
    }

    // MARK: - MediaThumbnailSlideshowViewControllerDelegate

    public func mediaThumbnailSlideshowViewController(_ thumbnailSlideshowViewController: MediaThumbnailSlideshowViewController, didSelectPreview preview: MediaPreviewable) {
        showPreview(preview, animated: false)
        updateCurrentPreviewViewController()
    }

}

private class ControllerCell: UICollectionViewCell {

    weak var viewController: MediaViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}


