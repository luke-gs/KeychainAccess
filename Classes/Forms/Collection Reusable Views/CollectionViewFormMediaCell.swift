//
//  CollectionViewFormMediaCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol MediaPreviewable: class {

    var thumbnailImage: ImageLoadable? { get }

    var title: String? { get }

}

public protocol MediaPreviewRenderer: DefaultReusable {

    associatedtype Media: MediaPreviewable

}

public let CollectionViewFormMediaCellMinimumItemHeight: CGFloat = 96.0

open class CollectionViewFormMediaCell<U: MediaPreviewableDelegate>: CollectionViewFormCell, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate {

    public weak var dataSource: MediaDataSource<U.Media>? {
        didSet {
            guard dataSource !== oldValue else { return }

            collectionView.reloadData()

            if let oldValue = oldValue {
                NotificationCenter.default.removeObserver(self, name: MediaDataSourceDidChangeNotificationName, object: oldValue)
            }

            if let dataSource = dataSource {
                NotificationCenter.default.addObserver(self, selector: #selector(mediaDataSourceDidChange(_:)), name: MediaDataSourceDidChangeNotificationName, object: dataSource)
            }

            updateContentState()
        }
    }

    public weak var delegate: U?

    public let collectionView: UICollectionView

    public let layout: UICollectionViewFlowLayout

    public let loadingManager: LoadingStateManager = LoadingStateManager()

    public weak var previewingController: UIViewController? {
        didSet {
            if let oldValue = oldValue, oldValue != previewingController {
                previewingContext.forEach {
                    oldValue.unregisterForPreviewing(withContext: $0.value)
                }
                previewingContext.removeAll()

                collectionView.reloadData()
            }
        }
    }

    private var mediaRenderers: [ObjectIdentifier: DefaultReusable.Type] = [:]

    private var previewingContext: [IndexPath: UIViewControllerPreviewing] = [:]

    public override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 96.0, height: 96.0)
        layout.minimumLineSpacing = 15.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24.0, bottom: 0, right: 24.0)
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)

        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        collectionView.register(MediaPreviewableCell.self)
        register(itemType: PhotoMedia.self, withRenderer: PhotoMediaCell.self)

        loadingManager.baseView = contentView
        loadingManager.contentView = collectionView

        let noContentView = loadingManager.noContentView
        noContentView.titleLabel.text = "No Photos"
        noContentView.subtitleLabel.text = "Add photos by tapping on 'Add' button."
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        previewingContext.forEach {
            previewingController?.unregisterForPreviewing(withContext: $0.value)
        }
    }


    /// Registers a renderer for a media type.
    ///
    /// - Parameters:
    ///   - itemType: The type of the media.
    ///   - renderer: The rendered for this media type.
    public func register<T: MediaPreviewRenderer & UICollectionViewCell>(itemType: T.Media.Type, withRenderer renderer: T.Type) {
        mediaRenderers[ObjectIdentifier(itemType)] = renderer
        collectionView.register(renderer)
    }

    // MARK: - UICollectionViewDelegate/DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfMediaItems() ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource, let item = dataSource.mediaItemAtIndex(indexPath.item) else { return UICollectionViewCell() }

        let rendererType = mediaRenderers[ObjectIdentifier(type(of: item))] ?? MediaPreviewableCell.self

        return collectionView.dequeueReusableCell(withReuseIdentifier: rendererType.defaultReuseIdentifier, for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MediaPreviewableCell {
            cell.media = dataSource?.mediaItemAtIndex(indexPath.item)
        }

        if let context = previewingController?.registerForPreviewing(with: self, sourceView: cell) {
            previewingContext[indexPath] = context
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let context = previewingContext.removeValue(forKey: indexPath) {
            previewingController?.unregisterForPreviewing(withContext: context)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource, let mediaItem = dataSource.mediaItemAtIndex(indexPath.item), let viewController = delegate?.mediaItemViewControllerForMediaItem(mediaItem, inDataSource: dataSource) else { return }

        previewingController?.present(viewController, animated: true, completion: nil)
    }

    // MARK: - UIViewControllerPreviewingDelegate

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let previewingController = previewingController,
            let dataSource = dataSource,
            let viewController = delegate?.viewControllerForMediaDataSource(dataSource, fromPreviewViewController: viewControllerToCommit) else { return }

        previewingController.present(viewController, animated: true, completion: nil)
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        if let key = self.previewingContext.first(where: { (key, value) -> Bool in
            return previewingContext.sourceView == value.sourceView
        })?.key {
            if let dataSource = dataSource, let mediaItem = dataSource.mediaItemAtIndex(key.item) {
                return delegate?.previewViewControllerForMediaItem(mediaItem, inDataSource: dataSource)
            }
        }

        return nil
    }

    // MARK: - Private

    @objc private func mediaDataSourceDidChange(_ notification: Notification) {
        collectionView.reloadData()
        updateContentState()
    }

    @objc private func addButtonTapped() {
        guard let previewingController = previewingController,
            let dataSource = dataSource,
            let viewController = delegate?.viewControllerForMediaDataSource(dataSource) else { return }

        previewingController.present(viewController, animated: true, completion: nil)
    }

    private func updateContentState() {
        loadingManager.state = (dataSource?.numberOfMediaItems() ?? 0) > 0 ? .loaded : .noContent
    }

}
