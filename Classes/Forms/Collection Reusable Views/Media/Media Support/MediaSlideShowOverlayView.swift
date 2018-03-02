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

    weak var slideShowViewController: (MediaSlideShowable & MediaSlideShowViewController)? { get set }

    func populateWithPreview(_ preview: MediaPreviewable)

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

    open override func layoutSubviews() {
        super.layoutSubviews()

        let height = collectionView.frame.height
        let inset = ((bounds.width - height) * 0.5) - mainItemInsets.left

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }

    public var slideShowViewController: (MediaSlideShowable & MediaSlideShowViewController)? {
        willSet {
            if let galleryViewModel = slideShowViewController?.viewModel {
                NotificationCenter.default.removeObserver(self, name: MediaGalleryDidChangeNotificationName, object: galleryViewModel)
            }
        }
        didSet {
            setupNavigationItems()
            if let preview = slideShowViewController?.currentPreview {
                updateDetailsWithPreview(preview)
            }

            if let galleryViewModel = slideShowViewController?.viewModel {
                NotificationCenter.default.addObserver(self, selector: #selector(galleryDidChange(_:)), name: MediaGalleryDidChangeNotificationName, object: galleryViewModel)
            }
        }
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard isHidden != hidden else { return }

        let finalColor: UIColor = hidden ? .black : .white

        hidingViewConstraint?.isActive = hidden

        if animated {

            let isCurrentlyHidden = isHidden
            // Unhide first so the view can be animated in.
            if isCurrentlyHidden && !hidden {
                isHidden = false
            }

            slideShowViewController?.view.backgroundColor = hidden ? .white : .black

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: {
                self.layoutIfNeeded()
                self.slideShowViewController?.view.backgroundColor = finalColor

            }, completion: { result in
                self.isHidden = hidden
                self.slideShowViewController?.view.backgroundColor = finalColor
            })
        } else {
            isHidden = hidden
            slideShowViewController?.view.backgroundColor = finalColor
        }

        slideShowViewController?.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    private func updateDetailsWithPreview(_ preview: MediaPreviewable) {
        guard let viewModel = slideShowViewController?.viewModel, let index = viewModel.indexOfPreview(preview) else { return }

        slideShowViewController?.navigationItem.title = String.localizedStringWithFormat("Asset %1$d of %2$d", index + 1, viewModel.previews.count)
        titleLabel.text = preview.title
        commentLabel.text = preview.comments

        titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
        commentLabel.isHidden = commentLabel.text?.isEmpty ?? true
        captionsBackgroundView.isHidden = titleLabel.isHidden && commentLabel.isHidden

        titleLabel.alpha = 0.0
        commentLabel.alpha = 0.0

        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [.calculationModeCubic], animations: {

            // Animate the UIStackView size changes first, triggered due to the titleLabel & commentLabel changes.
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                self.layoutIfNeeded()
            })

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7, animations: {
                self.titleLabel.alpha = 1.0
                self.commentLabel.alpha = 1.0
            })

        }, completion: nil)

    }

    public func populateWithPreview(_ preview: MediaPreviewable) {
        updateDetailsWithPreview(preview)

        if let index = slideShowViewController?.viewModel.indexOfPreview(preview) {
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
        return slideShowViewController?.viewModel.previews.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height

        guard let currentMedia = slideShowViewController?.currentPreview,
            let currentMediaIndex = slideShowViewController?.viewModel.indexOfPreview(currentMedia),
            currentMediaIndex == indexPath.section else {
            return CGSize(width: compactItemWidth, height: height)
        }

        return CGSize(width: collectionView.isDragging ? compactItemWidth : height, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let currentMedia = slideShowViewController?.currentPreview,
            let currentMediaIndex = slideShowViewController?.viewModel.indexOfPreview(currentMedia),
            currentMediaIndex == section else {
                return .zero
        }

        return collectionView.isDragging ? .zero : mainItemInsets
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let mediaAsset = slideShowViewController?.viewModel.previews[indexPath.section]

        mediaAsset?.thumbnailImage?.loadImage(completion: { (image) in
            let imageView = UIImageView(image: image.sizing().image)
            imageView.contentMode = .scaleAspectFill
            cell.backgroundView = imageView
            cell.clipsToBounds = true
        })

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mediaAsset = slideShowViewController?.viewModel.previews[indexPath.section] {
            slideShowViewController?.setupWithInitialPreview(mediaAsset)
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

        let index = max(Int(floor((offset + x) / compactItemWidth)), 0)

        if let preview = slideShowViewController?.viewModel.previews[index], preview !== slideShowViewController?.currentPreview {
            slideShowViewController?.setupWithInitialPreview(preview)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentPreview = slideShowViewController?.currentPreview,
            let currentPreviewIndex = slideShowViewController?.viewModel.indexOfPreview(currentPreview) else {
            return
        }

        let indexPath = IndexPath(item: 0, section: currentPreviewIndex)
        if collectionView.cellForItem(at: indexPath) != nil {
            collectionView.performBatchUpdates({
                self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            guard let currentPreview = slideShowViewController?.currentPreview,
                let currentPreviewIndex = slideShowViewController?.viewModel.indexOfPreview(currentPreview) else {
                    return
            }

            let indexPath = IndexPath(item: 0, section: currentPreviewIndex)
            if (collectionView.cellForItem(at: indexPath) != nil) {
                collectionView.performBatchUpdates({
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }, completion: nil)
            }
        }
    }

    // MARK: - PhotoMediaDetailViewControllerDelegate

    public func mediaDetailViewControllerDidUpdateMedia(_ detailViewController: MediaDetailViewController) {
        guard let slideShowViewController = slideShowViewController, let currentPhotoPreview = slideShowViewController.currentPreview else { return }

        populateWithPreview(currentPhotoPreview)
        _ = slideShowViewController.viewModel.replaceMedia(currentPhotoPreview.media, with: currentPhotoPreview.media)
    }

    // MARK: - Private

    @objc func closeTapped() {
        slideShowViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func removeTapped(_ item: UIBarButtonItem) {
        slideShowViewController?.handleDeletePreviewButtonTapped(item)
    }

    @objc func editTapped(_ item: UIBarButtonItem) {
        guard let slideShowViewController = slideShowViewController,
            let currentPreview = slideShowViewController.currentPreview else { return }

        let detailViewController = MediaDetailViewController(media: currentPreview.media)
        detailViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .formSheet

        slideShowViewController.present(navigationController, animated: true, completion: nil)
    }

    @objc func galleryDidChange(_ notification: Notification) {
        collectionView.reloadData()
    }

    private func setupNavigationItems() {
        if let navigationItem = slideShowViewController?.navigationItem {
            if slideShowViewController?.allowEditing == true {
                let removeItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeTapped(_:)))
                let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))

                navigationItem.rightBarButtonItems = [editItem, removeItem]
            } else {
                navigationItem.rightBarButtonItems = nil
            }
        }
    }


}
