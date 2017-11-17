//
//  PhotoMediaSlideShowOverlayView.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol PhotoMediaOverlayViewable: class {

    weak var galleryViewController: PhotoMediaSlideShowViewController? { get set }

    func populateWithPhoto(_ photo: PhotoMedia)

    func setHidden(_ hidden: Bool, animated: Bool)

    func view() -> UIView

}

extension PhotoMediaOverlayViewable where Self: UIView {

    public func view() -> UIView {
        return self
    }

}

public class PhotoMediaSlideShowOverlayView: UIView, PhotoMediaOverlayViewable, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PhotoMediaDetailViewControllerDelegate {

    public let toolbar = UIToolbar()

    public let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let titleLabel = UILabel()

    private let titleBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private let compactItemWidth: CGFloat = 30.0

    private let mainItemInsets = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)

    public override init(frame: CGRect) {
        super.init(frame: frame)

        toolbar.frame = CGRect(origin: CGPoint(x: 0.0, y: frame.height - toolbar.frame.height), size: CGSize(width: frame.width, height: toolbar.frame.height))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbar)

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0

        collectionView.frame = toolbar.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        toolbar.addSubview(collectionView)

        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)

        titleBackgroundView.contentView.addSubview(titleLabel)
        titleBackgroundView.layer.cornerRadius = 8.0
        titleBackgroundView.clipsToBounds = true
        addSubview(titleBackgroundView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleBackgroundView.contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleBackgroundView.contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleBackgroundView.contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleBackgroundView.contentView.layoutMarginsGuide.bottomAnchor),

            titleBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleBackgroundView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -16.0),

            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let height = collectionView.frame.height
        let inset = ((bounds.width - height) * 0.5) - mainItemInsets.left

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }

    public var galleryViewController: PhotoMediaSlideShowViewController? {
        willSet {
            if let galleryViewController = galleryViewController {
                NotificationCenter.default.removeObserver(self, name: MediaDataSourceDidChangeNotificationName, object: galleryViewController)
            }
        }
        didSet {
            setupNavigationItems()

            if let photo = galleryViewController?.currentPhotoMedia {
                updateDetailsWithPhoto(photo)
            }

            NotificationCenter.default.addObserver(self, selector: #selector(mediaDataSourceDidChange(_:)), name: MediaDataSourceDidChangeNotificationName, object: galleryViewController?.dataSource)
        }
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard isHidden != hidden else { return }

        if animated {
            alpha = hidden ? 1.0 : 0.0
            isHidden = hidden
            galleryViewController?.view.backgroundColor = hidden ? .white : .black

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: {
                self.alpha = hidden ? 0.0 : 1.0
                self.galleryViewController?.view.backgroundColor = hidden ? .black : .white
                self.galleryViewController?.navigationController?.navigationBar.isHidden = hidden
            }, completion: { result in
                self.alpha = 1.0
                self.isHidden = hidden
                self.galleryViewController?.view.backgroundColor = hidden ? .black : .white
            })
        } else {
            isHidden = hidden
            galleryViewController?.view.backgroundColor = hidden ? .black : .white
        }
    }

    private func updateDetailsWithPhoto(_ photo: PhotoMedia) {
        guard let dataSource = galleryViewController?.dataSource, let index = dataSource.indexOfMediaItem(photo) else { return }

        galleryViewController?.navigationItem.title = "Photo \(index + 1) of \(dataSource.numberOfMediaItems())"
        titleLabel.text = photo.title
        titleBackgroundView.isHidden = photo.title?.isEmpty ?? true
    }

    public func populateWithPhoto(_ photo: PhotoMedia) {
        updateDetailsWithPhoto(photo)

        if let index = galleryViewController?.dataSource.indexOfMediaItem(photo) {
            let indexPath = IndexPath(item: 0, section: index)
            if let cell = collectionView.cellForItem(at: indexPath) {
                if !collectionView.isDragging {
                    self.collectionView.scrollRectToVisible(cell.frame, animated: true)
                    collectionView.performBatchUpdates({
                        self.collectionView.collectionViewLayout.invalidateLayout()
                    }, completion: nil)
                }
            }
        }

        setupNavigationItems()
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event), view != self {
            return view
        }
        return nil
    }

    // MARK: - CollectionViewDelegate/DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return galleryViewController?.dataSource.numberOfMediaItems() ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height

        guard let photoMedia = galleryViewController?.currentPhotoMedia,
            let photoMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(photoMedia),
            photoMediaIndex == indexPath.section else {
            return CGSize(width: compactItemWidth, height: height)
        }

        return CGSize(width: collectionView.isDragging ? compactItemWidth : height, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let photoMedia = galleryViewController?.currentPhotoMedia,
            let photoMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(photoMedia),
            photoMediaIndex == section else {
                return .zero
        }

        return collectionView.isDragging ? .zero : mainItemInsets
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let photoMedia = galleryViewController?.dataSource.mediaItemAtIndex(indexPath.section)

        photoMedia?.thumbnailImage?.loadImage(completion: { (image) in
            let imageView = UIImageView(image: image.sizing().image)
            imageView.contentMode = .scaleAspectFill
            cell.backgroundView = imageView
            cell.clipsToBounds = true
        })

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photoMedia = galleryViewController?.dataSource.mediaItemAtIndex(indexPath.section) {
            galleryViewController?.setupWithInitialPhoto(photoMedia)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        let x = collectionView.contentOffset.x
        let offset: CGFloat
        if #available(iOS 11.0, *) {
            offset = collectionView.adjustedContentInset.left
        } else {
            offset = collectionView.contentInset.left
        }

        let index = Int(floor((offset + x) / compactItemWidth))

        if let photoMedia = galleryViewController?.dataSource.mediaItemAtIndex(index), photoMedia !== galleryViewController?.currentPhotoMedia {
            galleryViewController?.setupWithInitialPhoto(photoMedia)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let photoMedia = galleryViewController?.currentPhotoMedia,
            let photoMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(photoMedia) else {
            return
        }

        let indexPath = IndexPath(item: 0, section: photoMediaIndex)
        if collectionView.cellForItem(at: indexPath) != nil {
            collectionView.performBatchUpdates({
                self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            guard let photoMedia = galleryViewController?.currentPhotoMedia,
                let photoMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(photoMedia) else {
                    return
            }

            let indexPath = IndexPath(item: 0, section: photoMediaIndex)
            if (collectionView.cellForItem(at: indexPath) != nil) {
                collectionView.performBatchUpdates({
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }, completion: nil)
            }
        }
    }

    // MARK: - PhotoMediaDetailViewControllerDelegate

    public func photoMediaDetailViewControllerDidUpdatePhotoMedia(_ detailViewController: PhotoMediaDetailViewController) {
        guard let galleryViewController = galleryViewController, let currentPhotoMedia = galleryViewController.currentPhotoMedia else { return }

        populateWithPhoto(currentPhotoMedia)
        galleryViewController.dataSource.replaceMediaItem(currentPhotoMedia, with: currentPhotoMedia)
    }

    // MARK: - Private

    @objc func closeTapped() {
        galleryViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func removeTapped(_ item: UIBarButtonItem) {
        galleryViewController?.handleDeletePhotoButtonTapped(item)
    }

    @objc func editTapped(_ item: UIBarButtonItem) {
        guard let galleryViewController = galleryViewController, let currentPhotoMedia = galleryViewController.currentPhotoMedia else { return }

        let detailViewController = PhotoMediaDetailViewController(photoMedia: currentPhotoMedia)
        detailViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .formSheet

        galleryViewController.present(navigationController, animated: true, completion: nil)
    }

    @objc func mediaDataSourceDidChange(_ notification: Notification) {
        collectionView.reloadData()
    }

    private func setupNavigationItems() {
        if let navigationItem = galleryViewController?.navigationItem {
            if galleryViewController?.allowEditing == true {
                let removeItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeTapped(_:)))
                let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))

                navigationItem.rightBarButtonItems = [editItem, removeItem]
            } else {
                navigationItem.rightBarButtonItems = nil
            }
        }
    }


}
