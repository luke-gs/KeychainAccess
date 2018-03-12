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

    private enum Identifier: String {
        case genericCell
        case stateCell
    }
    
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

        if let initialPreview = initialPreview {
            setupWithInitialPreview(initialPreview, animated: false)
            self.initialPreview = nil
        }

        interfaceStyleDidChange()
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

        updateCurrentPreviewViewController()
    }

    // MARK: - UICollectionViewDelegate / DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch viewModel.state {
        case .completed(let hasAdditionalItems): return hasAdditionalItems ? 2 : 1
        case .unknown: return 2
        case .loading: return 2
        case .error: return 2
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
        return collectionView.bounds.size
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPreviewViewController()

        overlayView.populateWithPreview(currentPreview)
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

    private var controllerPool =  [Media: MediaViewController]()

    private func updateCurrentPreviewViewController() {
        let width = collectionView.bounds.width
        if width > 0.0, collectionView.contentOffset.x >= 0.0 {
            let index: Int = Int(floor(collectionView.contentOffset.x / width))
            if index >= viewModel.previews.count {
                currentPreviewViewController = nil
            } else {
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
                currentPreviewViewController = (cell as? ControllerCell)?.viewController as? MediaViewController
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

    @objc private func interfaceStyleDidChange() {
        guard isViewLoaded else { return }

        let theme = ThemeManager.shared.theme(for: .current)
        let backgroundColor = theme.color(forKey: .background)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        view.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        collectionView.reloadData()
    }
    
    // MARK: - Interaction
    
    @objc private func actionButtonTouched(_ button: UIButton) {
        if case .loading = viewModel.state {} else {
            viewModel.retrievePreviews(style: .paginated)
        }
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


