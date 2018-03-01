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

public class MediaSlideShowViewController: UIViewController, MediaSlideShowable, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {

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

    public init(viewModel: MediaGalleryViewModelable, initialPreview: MediaPreviewable? = nil, referenceView: UIView? = nil) {
        self.viewModel = viewModel
        self.initialPreview = initialPreview

        super.init(nibName: nil, bundle: nil)

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
            if let index = indexOfPreview(preview) {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            }
            overlayView.populateWithPreview(preview)
        }
    }

    public func showPreview(_ preview: MediaPreviewable, animated: Bool) {
        guard let index = indexOfPreview(preview), isViewLoaded else { return }

        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)

        overlayView.populateWithPreview(preview)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = .white

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
        collectionView.register(ControllerCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)

        collectionView.addGestureRecognizer(tapGestureRecognizer)
        self.overlayView.slideShowViewController = self

        if let initialPreview = initialPreview {
            setupWithInitialPreview(initialPreview, animated: false)
            self.initialPreview = nil
        }

        updateCurrentPreviewViewController()
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

    // MARK: - UICollectionViewDelegate / DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.previews.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ControllerCell

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ControllerCell else { return }

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
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ControllerCell else { return }

        if let previewController = cell.viewController {
            previewController.willMove(toParentViewController: nil)
            previewController.view.removeFromSuperview()
            previewController.removeFromParentViewController()
        }

        cell.viewController = nil
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPreviewViewController()

        if let currentPreview = currentPreview {
            overlayView.populateWithPreview(currentPreview)
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
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete Asset", comment: ""), style: .destructive, handler: { (action) in
            self.deleteCurrentPreview()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func updateCurrentPreviewViewController() {
        let width = collectionView.bounds.width
        if width > 0.0, collectionView.contentOffset.x >= 0.0 {
            let index: Int = Int(floor(collectionView.contentOffset.x / width))
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
            currentPreviewViewController = (cell as? ControllerCell)?.viewController as? MediaViewController
        }
    }

    private func previewViewControllerForPreview(_ preview: MediaPreviewable) -> UIViewController? {
        return viewModel.controllerForPreview(preview)
    }

    private func previewAfterDeletion(currentPreviewIndex index: Int) -> MediaPreviewable? {
        let numberOfPreviews = viewModel.previews.count
        guard numberOfPreviews >= 0 else { return nil }

        if index < numberOfPreviews {
            return viewModel.previews[index]
        }

        return viewModel.previews[index - 1]
    }

    private func deleteCurrentPreview() {
        guard let currentPreview = currentPreview else { return }

        if let index = indexOfPreview(currentPreview) {
            viewModel.removeMedia([currentPreview.media]).then { [weak self] _ -> () in
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
        overlayView.setHidden(isFullScreen, animated: animated)
        if isUIViewControllerBasedStatusBarAppearance {
            setNeedsStatusBarAppearanceUpdate()
        } else {
            let animation: UIStatusBarAnimation = animated ? .slide : .none
            UIApplication.shared.setStatusBarHidden(isFullScreen, with: animation)
        }
    }

    @objc private func galleryDidChange(_ notification: Notification) {
        guard isViewLoaded else { return }
        collectionView.reloadData()
    }

    // MARK: - Gesture Recognizers

    @objc private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        setFullScreen(!isFullScreen, animated: true)
    }

}

private class ControllerCell: UICollectionViewCell {

    weak var viewController: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
