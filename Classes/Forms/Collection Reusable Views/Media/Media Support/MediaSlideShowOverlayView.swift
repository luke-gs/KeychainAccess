//
//  MediaSlideShowOverlayView.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol MediaOverlayViewable: class {

    weak var galleryViewController: MediaSlideShowViewController? { get set }

    func populateWithMedia(_ media: MediaAsset)

    func setHidden(_ hidden: Bool, animated: Bool)

    func view() -> UIView

}

extension MediaOverlayViewable where Self: UIView {

    public func view() -> UIView {
        return self
    }

}

public class MediaSlideShowOverlayView: UIView, MediaOverlayViewable, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MediaDetailViewControllerDelegate {

    public let toolbar = UIToolbar()

    public let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let titleLabel = UILabel()
    private let commentLabel = UILabel()

    private let captionsBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private lazy var textStackView = UIStackView(arrangedSubviews: [titleLabel, commentLabel])

    private let compactItemWidth: CGFloat = 30.0

    private let textPadding: CGFloat = 12

    private let mainItemInsets = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)

    private var hidingViewConstraint: NSLayoutConstraint?

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

        captionsBackgroundView.clipsToBounds = true
        captionsBackgroundView.alpha = 0.75
        addSubview(captionsBackgroundView)

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        commentLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        commentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        commentLabel.textAlignment = .center
        commentLabel.numberOfLines = 4

        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.distribution = .fill
        textStackView.spacing = textPadding
        addSubview(textStackView)

        captionsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        hidingViewConstraint = captionsBackgroundView.topAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            captionsBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            captionsBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            captionsBackgroundView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            textStackView.leadingAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.leadingAnchor, constant: textPadding).withPriority(.almostRequired),
            textStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).withPriority(.almostRequired),
            textStackView.topAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.topAnchor, constant: textPadding),
            textStackView.bottomAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.bottomAnchor, constant: -textPadding),

            textStackView.centerXAnchor.constraint(equalTo: captionsBackgroundView.centerXAnchor),

            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor).withPriority(.defaultLow),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override public func updateConstraints() {
        super.updateConstraints()

    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let height = collectionView.frame.height
        let inset = ((bounds.width - height) * 0.5) - mainItemInsets.left

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }

    public var galleryViewController: MediaSlideShowViewController? {
        willSet {
            if let galleryViewController = galleryViewController {
                NotificationCenter.default.removeObserver(self, name: MediaDataSourceDidChangeNotificationName, object: galleryViewController)
            }
        }
        didSet {
            setupNavigationItems()
            if let media = galleryViewController?.currentMedia {
                updateDetailsWithMedia(media)
            }

            NotificationCenter.default.addObserver(self, selector: #selector(mediaDataSourceDidChange(_:)), name: MediaDataSourceDidChangeNotificationName, object: galleryViewController?.dataSource)
        }
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard isHidden != hidden else { return }

        let finalColor: UIColor = hidden ? .black : .white

        hidingViewConstraint?.isActive = hidden

        if animated {

            // Unhide first so the view can be animated in.
            if isHidden == true && hidden == false {
                isHidden = false
            }

            galleryViewController?.view.backgroundColor = hidden ? .white : .black

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: {
                self.layoutIfNeeded()
                self.galleryViewController?.view.backgroundColor = finalColor

            }, completion: { result in
                self.isHidden = hidden
                self.galleryViewController?.view.backgroundColor = finalColor
            })
        } else {
            isHidden = hidden
            galleryViewController?.view.backgroundColor = finalColor
        }

        galleryViewController?.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    private func updateDetailsWithMedia(_ media: MediaAsset) {
        guard let dataSource = galleryViewController?.dataSource, let index = dataSource.indexOfMediaItem(media) else { return }

        galleryViewController?.navigationItem.title = "Asset \(index + 1) of \(dataSource.numberOfMediaItems())"
        titleLabel.text = media.title
        commentLabel.text = media.comments

        titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
        commentLabel.isHidden = commentLabel.text?.isEmpty ?? true
        captionsBackgroundView.isHidden = titleLabel.isHidden && commentLabel.isHidden
    }

    public func populateWithMedia(_ media: MediaAsset) {
        updateDetailsWithMedia(media)

        if let index = galleryViewController?.dataSource.indexOfMediaItem(media) {
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

        guard let currentMedia = galleryViewController?.currentMedia,
            let currentMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(currentMedia),
            currentMediaIndex == indexPath.section else {
            return CGSize(width: compactItemWidth, height: height)
        }

        return CGSize(width: collectionView.isDragging ? compactItemWidth : height, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let currentMedia = galleryViewController?.currentMedia,
            let currentMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(currentMedia),
            currentMediaIndex == section else {
                return .zero
        }

        return collectionView.isDragging ? .zero : mainItemInsets
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let mediaAsset = galleryViewController?.dataSource.mediaItemAtIndex(indexPath.section)

        mediaAsset?.thumbnailImage?.loadImage(completion: { (image) in
            let imageView = UIImageView(image: image.sizing().image)
            imageView.contentMode = .scaleAspectFill
            cell.backgroundView = imageView
            cell.clipsToBounds = true
        })

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mediaAsset = galleryViewController?.dataSource.mediaItemAtIndex(indexPath.section) {
            galleryViewController?.setupWithInitialMedia(mediaAsset)
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

        if let mediaAsset = galleryViewController?.dataSource.mediaItemAtIndex(index), mediaAsset !== galleryViewController?.currentMedia {
            galleryViewController?.setupWithInitialMedia(mediaAsset)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentMedia = galleryViewController?.currentMedia,
            let currentMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(currentMedia) else {
            return
        }

        let indexPath = IndexPath(item: 0, section: currentMediaIndex)
        if collectionView.cellForItem(at: indexPath) != nil {
            collectionView.performBatchUpdates({
                self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            guard let currentMedia = galleryViewController?.currentMedia,
                let currentMediaIndex = galleryViewController?.dataSource.indexOfMediaItem(currentMedia) else {
                    return
            }

            let indexPath = IndexPath(item: 0, section: currentMediaIndex)
            if (collectionView.cellForItem(at: indexPath) != nil) {
                collectionView.performBatchUpdates({
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }, completion: nil)
            }
        }
    }

    // MARK: - PhotoMediaDetailViewControllerDelegate

    public func mediaDetailViewControllerDidUpdatePhotoMedia(_ detailViewController: MediaDetailViewController) {
        guard let galleryViewController = galleryViewController, let currentPhotoMedia = galleryViewController.currentMedia else { return }

        populateWithMedia(currentPhotoMedia)
        galleryViewController.dataSource.replaceMediaItem(currentPhotoMedia, with: currentPhotoMedia)
    }

    // MARK: - Private

    @objc func closeTapped() {
        galleryViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func removeTapped(_ item: UIBarButtonItem) {
        galleryViewController?.handleDeleteMediaButtonTapped(item)
    }

    @objc func editTapped(_ item: UIBarButtonItem) {
        guard let galleryViewController = galleryViewController,
            let currentMedia = galleryViewController.currentMedia else { return }

        let detailViewController = MediaDetailViewController(mediaAsset: currentMedia)
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
