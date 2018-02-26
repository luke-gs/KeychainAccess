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

    weak var slideShowViewController: (MediaSlideShowable & UIViewController)? { get set }

    func populateWithMedia(_ media: MediaPreviewable)

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
    private let commentsLabel = UILabel()

    private let titleBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private lazy var textStackView = UIStackView(arrangedSubviews: [titleLabel, commentsLabel])

    private let compactItemWidth: CGFloat = 30.0

    private let textPadding: CGFloat = 24

    private let mainItemInsets = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)

    private let tabletLandscapeWidth: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8
    private lazy var constraintTextAreaWidth = textStackView.widthAnchor.constraint(lessThanOrEqualToConstant: tabletLandscapeWidth)

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

        titleBackgroundView.clipsToBounds = true
        titleBackgroundView.alpha = 0.75
        addSubview(titleBackgroundView)

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        commentsLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        commentsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        commentsLabel.textAlignment = .center
        commentsLabel.numberOfLines = 4

        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.distribution = .fill
        textStackView.spacing = textPadding
        addSubview(textStackView)

        titleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleBackgroundView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            textStackView.leadingAnchor.constraint(equalTo: titleBackgroundView.leadingAnchor, constant: textPadding).withPriority(.almostRequired),
            textStackView.trailingAnchor.constraint(equalTo: titleBackgroundView.trailingAnchor, constant: -textPadding).withPriority(.almostRequired),
            textStackView.centerXAnchor.constraint(equalTo: titleBackgroundView.centerXAnchor),
            textStackView.topAnchor.constraint(equalTo: titleBackgroundView.topAnchor, constant: textPadding),
            textStackView.bottomAnchor.constraint(equalTo: titleBackgroundView.bottomAnchor, constant: -textPadding),


            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            constraintTextAreaWidth.isActive = true
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override public func updateConstraints() {
        super.updateConstraints()
        titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
        commentsLabel.isHidden = commentsLabel.text?.isEmpty ?? true
        titleBackgroundView.isHidden = (titleLabel.text?.isEmpty ?? true) && (commentsLabel.text?.isEmpty ?? true)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let height = collectionView.frame.height
        let inset = ((bounds.width - height) * 0.5) - mainItemInsets.left

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }

    public var slideShowViewController: (MediaSlideShowable & UIViewController)? {
        willSet {
            if let slideShowViewController = slideShowViewController {
                // FIXME:
//                NotificationCenter.default.removeObserver(self, name: MediaDataSourceDidChangeNotificationName, object: slideShowViewController.dataSource)
            }
        }
        didSet {
            setupNavigationItems()
            if let media = slideShowViewController?.currentMedia {
                updateDetailsWithMedia(media)
            }

            // FIXME:
//            NotificationCenter.default.addObserver(self, selector: #selector(mediaDataSourceDidChange(_:)), name: MediaDataSourceDidChangeNotificationName, object: slideShowViewController?.dataSource)
        }
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard isHidden != hidden else { return }

        let finalColor: UIColor = hidden ? .black : .white

        if animated {
            alpha = hidden ? 1.0 : 0.0
            isHidden = hidden
            slideShowViewController?.view.backgroundColor = hidden ? .white : .black

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: {
                self.alpha = hidden ? 0.0 : 1.0
                self.slideShowViewController?.view.backgroundColor = finalColor
                self.slideShowViewController?.navigationController?.navigationBar.isHidden = hidden
            }, completion: { result in
                self.alpha = 1.0
                self.isHidden = hidden
                self.slideShowViewController?.view.backgroundColor = finalColor
            })
        } else {
            isHidden = hidden
            slideShowViewController?.view.backgroundColor = finalColor
        }
    }

    private func updateDetailsWithMedia(_ media: MediaPreviewable) {
        guard let viewModel = slideShowViewController?.viewModel, let index = viewModel.indexOfPreview(media) else { return }

        slideShowViewController?.navigationItem.title = "Asset \(index + 1) of \(viewModel.previews.count)"
        titleLabel.text = media.title
        commentsLabel.text = media.comments

        setNeedsUpdateConstraints()
    }

    public func populateWithMedia(_ media: MediaPreviewable) {
        updateDetailsWithMedia(media)

        if let index = slideShowViewController?.viewModel.indexOfPreview(media) {
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

        guard let currentMedia = slideShowViewController?.currentMedia,
            let currentMediaIndex = slideShowViewController?.viewModel.indexOfPreview(currentMedia),
            currentMediaIndex == indexPath.section else {
            return CGSize(width: compactItemWidth, height: height)
        }

        return CGSize(width: collectionView.isDragging ? compactItemWidth : height, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let currentMedia = slideShowViewController?.currentMedia,
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
            slideShowViewController?.setupWithInitialMedia(mediaAsset)
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

        if let mediaAsset = slideShowViewController?.viewModel.previews[index], mediaAsset !== slideShowViewController?.currentMedia {
            slideShowViewController?.setupWithInitialMedia(mediaAsset)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentMedia = slideShowViewController?.currentMedia,
            let currentMediaIndex = slideShowViewController?.viewModel.indexOfPreview(currentMedia) else {
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
            guard let currentMedia = slideShowViewController?.currentMedia,
                let currentMediaIndex = slideShowViewController?.viewModel.indexOfPreview(currentMedia) else {
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
        guard let slideShowViewController = slideShowViewController, let currentPhotoMedia = slideShowViewController.currentMedia else { return }

        populateWithMedia(currentPhotoMedia)
        slideShowViewController.viewModel.replaceMedia(currentPhotoMedia.asset, with: currentPhotoMedia.asset)
    }

    // MARK: - Private

    @objc func closeTapped() {
        slideShowViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func removeTapped(_ item: UIBarButtonItem) {
//        slideShowViewController?.handleDeleteMediaButtonTapped(item)
    }

    @objc func editTapped(_ item: UIBarButtonItem) {
        guard let slideShowViewController = slideShowViewController,
            let currentMedia = slideShowViewController.currentMedia else { return }

        let detailViewController = MediaDetailViewController(mediaAsset: currentMedia)
        detailViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .formSheet

        slideShowViewController.present(navigationController, animated: true, completion: nil)
    }

    @objc func mediaDataSourceDidChange(_ notification: Notification) {
        collectionView.reloadData()

    }

    private func setupNavigationItems() {
        if let navigationItem = slideShowViewController?.navigationItem {
//            if slideShowViewController?.allowEditing == true {
//                let removeItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeTapped(_:)))
//                let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))
//
//                navigationItem.rightBarButtonItems = [editItem, removeItem]
//            } else {
//                navigationItem.rightBarButtonItems = nil
//            }
        }
    }


}
