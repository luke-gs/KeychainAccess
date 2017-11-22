//
//  PhotoMediaGalleryViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import AVFoundation
import Photos



public class PhotoMediaGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private enum Identifier: String {
        case genericCell
    }

    public let collectionViewFlowLayout = UICollectionViewFlowLayout()

    public private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)

    public let dataSource: MediaDataSource<PhotoMedia>

    public let pickerSources: [PhotoMediaPickerSource]

    public var allowEditing: Bool = true {
        didSet { setupNavigationItems() }
    }

    public private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()

    private var initialPhoto: PhotoMedia?

    private lazy var addBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: ""), style: .plain, target: self, action: #selector(addButtonTapped))

    public init(dataSource: MediaDataSource<PhotoMedia>, initialPhoto: PhotoMedia? = nil, pickerSources: [PhotoMediaPickerSource] = [CameraMediaPicker(), PhotoLibraryMediaPicker()]) {

        pickerSources.forEach {
            $0.savePhotoMedia = {
                let photoMedia = PhotoMedia(thumbnailImage: $0, image: $0)
                dataSource.addMediaItem(photoMedia)
            }
        }

        self.dataSource = dataSource
        self.pickerSources = pickerSources
        self.initialPhoto = initialPhoto

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Photos", comment: "")

        setupNavigationItems()

        NotificationCenter.default.addObserver(self, selector: #selector(mediaDataSourceDidChange(_:)), name: MediaDataSourceDidChangeNotificationName, object: dataSource)
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureLayoutForCurrentTraitCollection()

        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Identifier.genericCell.rawValue)
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

        let noContentView = loadingManager.noContentView
        noContentView.titleLabel.text = NSLocalizedString("No Photos", comment: "")
        noContentView.subtitleLabel.text = NSLocalizedString("Add photos by tapping on 'Add' button.", comment: "")
        noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)

        let button = noContentView.actionButton
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        navigationController?.delegate = self

        updateContentState()
        interfaceStyleDidChange()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let initialPhoto = initialPhoto {
            let mediaGalleryViewController = PhotoMediaSlideShowViewController(dataSource: dataSource, initialPhotoMedia: initialPhoto, referenceView: nil)
            mediaGalleryViewController.allowEditing = allowEditing
            mediaGalleryViewController.mediaOverviewViewController = self
            navigationController?.pushViewController(mediaGalleryViewController, animated: true)

            self.initialPhoto = nil
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
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfMediaItems()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.genericCell.rawValue, for: indexPath)

        let photoMedia = dataSource.mediaItemAtIndex(indexPath.item)
        photoMedia?.thumbnailImage?.loadImage(completion: { [weak self] (sizable) in
            let imageView = UIImageView(image: sizable.sizing().image)
            imageView.contentMode = self?.traitCollection.horizontalSizeClass == .compact ? .scaleAspectFill : .scaleAspectFit
            imageView.clipsToBounds = true
            cell.backgroundView = imageView
            if self?.isEditing == true {
                cell.backgroundView?.alpha = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true ? 1.0 : 0.4
            }
        })

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        if isEditing {
            cell.backgroundView?.alpha = 1.0
            trashItem.isEnabled = true
        } else {
            let photoMedia = dataSource.mediaItemAtIndex(indexPath.item)
            let mediaGalleryViewController = PhotoMediaSlideShowViewController(dataSource: dataSource, initialPhotoMedia: photoMedia, referenceView: cell)
            mediaGalleryViewController.allowEditing = allowEditing
            mediaGalleryViewController.mediaOverviewViewController = self
            show(mediaGalleryViewController, sender: self)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            cell.backgroundView?.alpha = 0.4

            trashItem.isEnabled = (collectionView.indexPathsForSelectedItems?.count ?? 0) > 0
        }
    }


    // MARK: - Private

    private lazy var trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(_:)))

    private lazy var beginSelectItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(beginSelectTapped(_:)))

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
                navigationItem.rightBarButtonItems = [
                    beginSelectItem,
                    spacer,
                    addBarButtonItem
                ]
            } else {
                navigationItem.rightBarButtonItems = nil
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
        let alertController = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)

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

    @objc private func deleteTapped(_ item: UIBarButtonItem) {
        guard let indexPaths = collectionView.indexPathsForSelectedItems, indexPaths.count > 0 else { return }

        let numberOfPhotos = indexPaths.count

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete \(numberOfPhotos) Photo\(numberOfPhotos == 1 ? "" : "s")", style: .destructive, handler: { [weak self] (action) in
            guard let `self` = self else { return }

            indexPaths.flatMap({ self.dataSource.mediaItemAtIndex($0.item) }).forEach({
                self.dataSource.removeMediaItem($0)
            })

            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: indexPaths)
            }, completion: { (completed) in
                if self.dataSource.numberOfMediaItems() <= 0 {
                    self.setEditing(false, animated: true)
                }
            })
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = item
        present(alertController, animated: true, completion: nil)
    }

    @objc private func mediaDataSourceDidChange(_ notification: Notification) {
        guard isViewLoaded else { return }

        if !isEditing {
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
    }

    private func updateContentState() {
        let hasMediaItems = dataSource.numberOfMediaItems() > 0
        loadingManager.state = hasMediaItems ? .loaded : .noContent
        beginSelectItem.isEnabled = hasMediaItems
    }

    // MARK: - UINavigationControllerDelegate

    internal let transitionAnimator = PhotoMediaGalleryTransitionAnimator()

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            guard let _ = fromVC as? PhotoMediaGalleryViewController,
                let toVC = toVC as? PhotoMediaSlideShowViewController,
                let photoMedia = toVC.currentPhotoMedia,
                let photoMediaIndex = dataSource.indexOfMediaItem(photoMedia),
                let cell = collectionView.cellForItem(at: IndexPath(item: photoMediaIndex, section: 0)),
                let endingView = toVC.currentMediaViewController?.scalingImageView.imageView else { return nil }

            transitionAnimator.startingView = cell.backgroundView
            transitionAnimator.endingView = endingView
            transitionAnimator.dismissing = false
            return transitionAnimator
        case .pop:
            guard let fromVC = fromVC as? PhotoMediaSlideShowViewController,
                let _ = toVC as? PhotoMediaGalleryViewController,
                let endingView = fromVC.currentMediaViewController?.scalingImageView.imageView,
                let photoMedia = fromVC.currentPhotoMedia,
                let index = dataSource.indexOfMediaItem(photoMedia) else { return nil }

            let indexPath = IndexPath(item: index, section: 0)

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
