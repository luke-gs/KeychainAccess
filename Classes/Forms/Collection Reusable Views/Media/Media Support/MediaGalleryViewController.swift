//
//  MediaGalleryViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import PromiseKit

public class MediaGalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private enum Identifier: String {
        case genericCell
        case stateCell
    }

    public let collectionViewFlowLayout = UICollectionViewFlowLayout()

    public private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)

    public let pickerSources: [MediaPickerSource]

    public var allowEditing: Bool = true {
        didSet { setupNavigationItems() }
    }
    
    // App can provide additional bar button items.
    public var additionalBarButtonItems: [UIBarButtonItem]? {
        didSet {
            setupNavigationItems()
        }
    }

    public private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()

    private var initialPreview: MediaPreviewable?

    private lazy var addBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: ""), style: .plain, target: self, action: #selector(addButtonTapped))

    public let viewModel: MediaGalleryViewModelable

    private var itemsBeingProcessed: [Media] = []

    public init(viewModel: MediaGalleryViewModelable, initialPreview: MediaPreviewable? = nil, pickerSources: [MediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker(), AudioMediaPicker(), SketchMediaPicker()]) {

        self.viewModel = viewModel
        self.pickerSources = pickerSources
        self.initialPreview = initialPreview

        super.init(nibName: nil, bundle: nil)

        pickerSources.forEach {
            $0.saveMedia = { [weak self] media in
                guard let `self` = self else { return }

                firstly { () -> Promise<Bool> in
                    self.itemsBeingProcessed.append(media)
                    return self.viewModel.addMedia([media])
                }.then { _ -> () in
                    self.collectionView.reloadData()
                }.always {
                    if let index = self.itemsBeingProcessed.index(where: { $0 == media }) {
                        self.itemsBeingProcessed.remove(at: index)
                    }
                }
            }
        }

        title = NSLocalizedString("Gallery", comment: "")

        setupNavigationItems()

        NotificationCenter.default.addObserver(self, selector: #selector(galleryDidChange), name: MediaGalleryDidChangeNotificationName, object: viewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        pickerSources.forEach { $0.saveMedia = nil }
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureLayoutForCurrentTraitCollection()

        collectionView.backgroundColor = .white

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Identifier.genericCell.rawValue)
        collectionView.register(MediaStateCell.self, forCellWithReuseIdentifier: Identifier.stateCell.rawValue)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        view.addSubview(collectionView)

        loadingManager.baseView = view
        loadingManager.contentView = collectionView

        navigationController?.delegate = self

        configureLoadingManager()
        updateContentState()
        interfaceStyleDidChange()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let initialPhoto = initialPreview {
            let slideShowViewController = MediaSlideShowViewController(viewModel: viewModel, initialPreview: initialPhoto, referenceView: nil)
            slideShowViewController.allowEditing = allowEditing
            navigationController?.pushViewController(slideShowViewController, animated: true)

            self.initialPreview = nil
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11, *) {
            return
        }

        var insets = UIEdgeInsets()
        insets.top += topLayoutGuide.length
        insets.bottom += max(bottomLayoutGuide.length, statusTabBarInset)

        collectionView.contentInset = insets
    }

    // MARK: - Trait Collection

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureLayoutForCurrentTraitCollection()
        collectionView.reloadData()
    }

    private func configureLayoutForCurrentTraitCollection() {
        let horizontalSizeClass = traitCollection.horizontalSizeClass

        let layout = collectionViewFlowLayout
        let itemSize = horizontalSizeClass == .compact ? CGSize(width: 96.0, height: 96.0) : CGSize(width: 132.0, height: 132.0)
        let width = collectionView.bounds.width
        let itemsPerRow = floor(width / itemSize.width)
        let spacing = (width - (itemsPerRow * itemSize.width)) / (itemsPerRow + 1)

        layout.itemSize = itemSize
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

    // MARK: - UICollectionViewDataSource/Delegate

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch viewModel.state {
        case .completed(let hasAdditionalItems): return hasAdditionalItems ? 2 : 1
        case .unknown: return 2
        case .loading: return 2
        case .error: return 2
        case .noContents: return 1
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? viewModel.previews.count : 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.genericCell.rawValue, for: indexPath)

            cell.backgroundView = nil

            let preview = viewModel.previews[indexPath.item]
            preview.thumbnailImage?.loadImage(completion: { [weak self] (sizable) in
                let imageView = UIImageView(image: sizable.sizing().image)
                imageView.contentMode = self?.traitCollection.horizontalSizeClass == .compact ? .scaleAspectFill : .scaleAspectFit
                imageView.clipsToBounds = true
                cell.backgroundView = imageView
                if self?.isEditing == true {
                    cell.backgroundView?.alpha = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true ? 1.0 : 0.4
                }
            })

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

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        if indexPath.section == 0 {
            if isEditing {
                cell.backgroundView?.alpha = 1.0
                trashItem.isEnabled = true
            } else {
                let preview = viewModel.previews[indexPath.item]
                let mediaSlideShowViewController = MediaSlideShowViewController(viewModel: viewModel, initialPreview: preview, referenceView: cell)
                mediaSlideShowViewController.allowEditing = allowEditing
                show(mediaSlideShowViewController, sender: self)
            }
        } else {
            if case .loading = viewModel.state {} else {
                viewModel.retrievePreviews(style: .paginated)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            cell.backgroundView?.alpha = 0.4

            trashItem.isEnabled = (collectionView.indexPathsForSelectedItems?.count ?? 0) > 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.section == 0 {
            return traitCollection.horizontalSizeClass == .compact ? CGSize(width: 96.0, height: 96.0) : CGSize(width: 176.0, height: 176.0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 176.0)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = cell as? MediaStateCell {
                cell.apply(theme: ThemeManager.shared.theme(for: .current))
            }
        }
    }

    // MARK: - Private

    private lazy var trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(_:)))

    private lazy var beginSelectItem = UIBarButtonItem(title: NSLocalizedString("Select", comment: "Action to select assets"), style: .plain, target: self, action: #selector(beginSelectTapped(_:)))

    private lazy var endSelectItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endSelectTapped(_:)))

    private func setupNavigationItems() {
        if isEditing {
            trashItem.isEnabled = false
            navigationItem.leftBarButtonItem = trashItem
            navigationItem.rightBarButtonItems = [endSelectItem]

            collectionView.allowsMultipleSelection = true
        } else {
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer.width = 16.0
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeTapped))

            if allowEditing {
                var items = [beginSelectItem, spacer, addBarButtonItem]
                
                if let additionalBarButtonItems = additionalBarButtonItems {
                    items.append(contentsOf: additionalBarButtonItems)
                }
                
                navigationItem.rightBarButtonItems = items
            } else {
                navigationItem.rightBarButtonItems = additionalBarButtonItems
            }

            collectionView.allowsMultipleSelection = false
        }
    }

    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setupNavigationItems()
        collectionView.reloadData()
    }

    @objc private func beginSelectTapped(_ item: UIBarButtonItem) {
        self.setEditing(true, animated: true)
    }

    @objc private func endSelectTapped(_ item: UIBarButtonItem) {
        self.setEditing(false, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func addButtonTapped() {
        let alertController = UIAlertController(title: NSLocalizedString("Choose Asset", comment: ""), message: nil, preferredStyle: .actionSheet)

        pickerSources.forEach({ source in
            let action = UIAlertAction(title: source.title, style: .default, handler: { _ in
                let viewController = source.viewController()
                if let popoverPresentationController = viewController.popoverPresentationController, viewController.modalPresentationStyle == .popover {
                    popoverPresentationController.barButtonItem = self.addBarButtonItem
                }
                self.present(viewController, animated: true, completion: nil)
            })
            alertController.addAction(action)
        })

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = addBarButtonItem
        present(alertController, animated: true, completion: nil)
    }

    @objc private func refreshButtonTapped() {
        viewModel.retrievePreviews(style: .reset)
    }

    @objc private func deleteTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = collectionView.indexPathsForSelectedItems, indexPaths.count > 0 else { return }

        let numberOfItems = indexPaths.count

        let deleteTitle = String.localizedStringWithFormat(NSLocalizedString("Delete %1$d Asset(s)", comment: "Action to delete selected assets"), numberOfItems)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: deleteTitle, style: .destructive, handler: { [weak self] (action) in
            guard let `self` = self else { return }

            let items = indexPaths.map{ indexPath in
                self.viewModel.previews[indexPath.item].media
            }

            firstly { () -> Promise<Bool> in
                self.itemsBeingProcessed += items
                return self.viewModel.removeMedia(items)
            }.then { _ -> () in
                if self.viewModel.previews.count <= 0 {
                    self.setEditing(false, animated: true)
                } else {
                    self.collectionView.reloadData()
                }
            }.always {
                self.itemsBeingProcessed = self.itemsBeingProcessed.filter({ !items.contains($0) })
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    @objc private func galleryDidChange(_ notification: Notification) {
        guard isViewLoaded else { return }

        if itemsBeingProcessed.count == 0 {
            collectionView.reloadData()
        }

        updateContentState()
    }

    @objc private func interfaceStyleDidChange() {
        guard isViewLoaded else { return }

        let theme = ThemeManager.shared.theme(for: .current)
        let backgroundColor = theme.color(forKey: .background)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        loadingManager.noContentColor = secondaryTextColor ?? .gray
        view.backgroundColor = backgroundColor

        collectionView.backgroundColor = backgroundColor
    }
    
    @objc private func actionButtonTouched(_ button: UIButton) {
        if case .loading = viewModel.state {} else {
            viewModel.retrievePreviews(style: .paginated)
        }
    }

    private func updateContentState() {
        let hasPreviews = viewModel.previews.count > 0

        if hasPreviews {
            loadingManager.state = .loaded
        } else {
            switch viewModel.state {
            case .loading:
                loadingManager.state = .loading
            case .error:
                updateErrorState()
                loadingManager.state = .error
            case .completed, .unknown, .noContents:
                updateNoContentsState()
                loadingManager.state = .noContent
            }
        }

        beginSelectItem.isEnabled = hasPreviews
    }

    private func configureLoadingManager() {
        updateNoContentsState()
        updateLoadingState()
    }
    
    private func updateLoadingState() {
        loadingManager.loadingView.titleLabel.text = viewModel.titleForState(.loading)
        loadingManager.loadingView.subtitleLabel.text = viewModel.descriptionForState(.loading)
    }
    
    private func updateNoContentsState() {
        let noContentView = loadingManager.noContentView
        
        noContentView.titleLabel.text = viewModel.titleForState(.noContents)
        noContentView.subtitleLabel.text = viewModel.descriptionForState(.noContents)
        noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
    }
    
    private func updateErrorState() {
        let errorView = loadingManager.errorView
        let state = viewModel.state
        
        errorView.titleLabel.text = viewModel.titleForState(state)
        errorView.subtitleLabel.text = viewModel.descriptionForState(state)
    }

    // MARK: - UINavigationControllerDelegate

    internal let transitionAnimator = MediaGalleryTransitionAnimator()

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            guard let _ = fromVC as? MediaGalleryViewController,
                let toVC = toVC as? MediaSlideShowViewController,
                let preview = toVC.currentPreview,
                let previewIndex = viewModel.previews.index(where: { preview === $0 }),
                let cell = collectionView.cellForItem(at: IndexPath(item: previewIndex, section: 0)),
                let previewViewController = toVC.currentPreviewViewController
                else { return nil }

            let endingView = previewViewController.scalingImageView.imageView
            transitionAnimator.startingView = cell.backgroundView
            transitionAnimator.endingView = endingView
            transitionAnimator.dismissing = false
            return transitionAnimator
        case .pop:
            guard let fromVC = fromVC as? MediaSlideShowViewController,
                let _ = toVC as? MediaGalleryViewController,
                let previewViewController = fromVC.currentPreviewViewController,
                let preview = fromVC.currentPreview,
                let previewIndex = viewModel.previews.index(where: { preview === $0 }) else { return nil }

            let endingView = previewViewController.scalingImageView.imageView
            let indexPath = IndexPath(item: previewIndex, section: 0)

            if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                collectionView.layoutIfNeeded()
            }

            let cell = collectionView.cellForItem(at: indexPath)

            transitionAnimator.startingView = endingView
            transitionAnimator.endingView = cell?.backgroundView
            transitionAnimator.dismissing = true
            return transitionAnimator
        default:
            return nil
        }
    }
}
