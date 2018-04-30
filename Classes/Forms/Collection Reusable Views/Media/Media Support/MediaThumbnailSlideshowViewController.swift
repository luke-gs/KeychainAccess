//
//  MediaThumbnailSlideshowViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 20/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol MediaThumbnailSlideshowViewControllerDelegate: class {

    func mediaThumbnailSlideshowViewController(_ thumbnailSlideshowViewController: MediaThumbnailSlideshowViewController, didSelectPreview preview: MediaPreviewable)

}

public class MediaThumbnailSlideshowViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    static fileprivate let focusedItemWidth: CGFloat = 60.0
    static fileprivate let itemWidth: CGFloat = 40.0
    static fileprivate let itemSpacing: CGFloat = 1.0

    public let viewModel: MediaGalleryViewModelable
    public weak var delegate: MediaThumbnailSlideshowViewControllerDelegate?

    private var layout: ThumbnailLayout!
    private var collectionView: UICollectionView!

    private var focusedIndex: Int = 0

    public init(viewModel: MediaGalleryViewModelable) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(galleryDidChange(_:)), name: MediaGalleryDidChangeNotificationName, object: viewModel)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let toolbar = UIToolbar(frame: view.bounds)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.frame = view.bounds
        view.addSubview(toolbar)

        layout = ThumbnailLayout()
        layout.focusedItemWidth = MediaThumbnailSlideshowViewController.focusedItemWidth
        layout.itemWidth = MediaThumbnailSlideshowViewController.itemWidth
        layout.itemSpacing = MediaThumbnailSlideshowViewController.itemSpacing

        let insetY = 1.0 / traitCollection.currentDisplayScale
        let collectionViewFrame = view.bounds.insetBy(dx: 0, dy: insetY)

        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "Cell")

        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubview(collectionView)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (context) in
            self.scrollToItemAtIndex(self.focusedIndex, animated: false)
        })
    }

    // MARK: - Content changes

    @objc private func galleryDidChange(_ notification: Notification) {
        guard isViewLoaded else { return }

        collectionView.reloadData()
    }

    // MARK: - Operations

    public func setFocusedIndex(_ index: Int, animated: Bool) {
        guard focusedIndex != index else { return }
        focusedIndex = index

        scrollToItemAtIndex(index, animated: animated)
    }

    private func scrollToItemAtIndex(_ index: Int, animated: Bool) {
        guard isViewLoaded else { return }

        if collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) == nil {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }

        let itemWidth = MediaThumbnailSlideshowViewController.itemWidth
        let spacing = MediaThumbnailSlideshowViewController.itemSpacing
        let pageWidth = itemWidth + spacing
        let x = CGFloat(index) * pageWidth

        let offset = CGPoint(x: x, y: 0)

        collectionView.setContentOffset(offset, animated: animated)
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.previews.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbnailCell
        let preview = viewModel.previews[indexPath.item]

        preview.thumbnailImage?.loadImage(completion: { (image) in
            cell.imageView.image = image.sizing().image
        })

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setFocusedIndex(indexPath.item, animated: true)
        notifySelectionOfFocusedIndex()
    }

    private func notifySelectionOfFocusedIndex() {
        let preview = viewModel.previews[focusedIndex]
        delegate?.mediaThumbnailSlideshowViewController(self, didSelectPreview: preview)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let focusedItemIndex = layout.focusedItemIndex

        guard scrollView.isDragging || scrollView.isDecelerating, focusedItemIndex != focusedIndex else { return }

        focusedIndex = focusedItemIndex
        notifySelectionOfFocusedIndex()
    }

}

private class ThumbnailCell: UICollectionViewCell {

    public let imageView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        let maxWidth = MediaThumbnailSlideshowViewController.focusedItemWidth
        let minWidth = MediaThumbnailSlideshowViewController.itemWidth

        let delta = (frame.width - minWidth) / (maxWidth - minWidth)

        let minAlpha: CGFloat = 0.8
        let maxAlpha: CGFloat = 1.0

        imageView.alpha = (maxAlpha - minAlpha) * delta + minAlpha
    }

}

private class ThumbnailLayout: UICollectionViewLayout {

    public var focusedItemWidth: CGFloat = 60.0 {
        didSet {
            guard oldValue != focusedItemWidth else { return }
            invalidateLayout()
        }
    }

    public var itemWidth: CGFloat = 30.0 {
        didSet {
            guard oldValue != itemWidth else { return }
            invalidateLayout()
        }
    }

    public var itemSpacing: CGFloat = 1.0 {
        didSet {
            guard oldValue != itemSpacing else { return }
            invalidateLayout()
        }
    }

    public var focusedItemIndex: Int {
        let target = collectionView!.contentOffset
        let offset = collectionView!.contentInset.left
        let origin = target.x + offset

        let index = Int((origin / pageWidth).rounded(.toNearestOrAwayFromZero))
        return max(min(index, numberOfItems - 1), 0)
    }

    private var cache = [UICollectionViewLayoutAttributes]()

    private var pageIndex: Int {
        let target = collectionView!.contentOffset
        let offset = collectionView!.contentInset.left
        let origin = target.x + offset

        let index = Int((origin / pageWidth).rounded(.down))
        return max(min(index, numberOfItems - 1), 0)
    }

    private var nextPagePercentage: CGFloat {
        let target = collectionView!.contentOffset
        let offset = collectionView!.contentInset.left
        var origin = target.x + offset

        origin = max(min(origin, (CGFloat(numberOfItems) - 1.0) * pageWidth), 0)

        return (origin / pageWidth) - (origin / pageWidth).rounded(.down)
    }

    private var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }

    private var pageWidth: CGFloat {
        return itemWidth + itemSpacing
    }

    public override var collectionViewContentSize: CGSize {
        return CGSize(width: (CGFloat(numberOfItems) - 1.0) * pageWidth + collectionView!.frame.width, height: collectionView!.bounds.height)
    }

    private var previousLayoutDetail: (pageIndex: Int, count: Int, width: CGFloat) = (pageIndex: 0, count: 0, width: 0)

    public override func prepare() {
        let frame = collectionView!.frame
        let height = frame.height
        let width = frame.width
        let numberOfItems = self.numberOfItems
        let pageIndex = self.pageIndex
        let nextPageIndex = pageIndex + 1
        let nextPagePercentage = self.nextPagePercentage
        let currentPagePercentage = 1.0 - nextPagePercentage
        let additionalWidth = focusedItemWidth - itemWidth

        // Optimisation - Modify the two layout attributes that are changing and leave the rest the same.
        // If there are any issues with the layout, try removing this block of code first. But there shouldn't be any.
        if previousLayoutDetail.pageIndex == pageIndex &&
            cache.count == numberOfItems &&
            previousLayoutDetail.count == cache.count &&
            previousLayoutDetail.width == width {
            let currentLayoutAttributes = cache[pageIndex]
            var currentFrame = currentLayoutAttributes.frame

            currentFrame.size.width = additionalWidth * currentPagePercentage + itemWidth

            currentLayoutAttributes.frame = currentFrame

            if nextPageIndex < numberOfItems {
                let nextLayoutAttributes = cache[nextPageIndex]

                var frame = nextLayoutAttributes.frame

                frame.origin.x = currentFrame.maxX + itemSpacing
                frame.size.width = additionalWidth * nextPagePercentage + itemWidth

                nextLayoutAttributes.frame = frame
            }

            return
        }
        // End Optimisation

        cache.removeAll()

        var x: CGFloat = (collectionView!.frame.width - focusedItemWidth) * 0.5
        for item in 0..<numberOfItems {
            var width = itemWidth

            if item == pageIndex {
                width += additionalWidth * currentPagePercentage
            } else if item == nextPageIndex {
                width += additionalWidth * nextPagePercentage
            }

            let frame = CGRect(x: x, y: 0, width: width, height: height)

            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            attributes.frame = frame
            cache.append(attributes)

            x = frame.maxX + itemSpacing
        }

        previousLayoutDetail = (pageIndex: pageIndex, count: numberOfItems, width: width)
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { (attributes) -> Bool in
            attributes.frame.intersects(rect)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }


    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var target = proposedContentOffset
        let offset = itemSpacing
        let origin = target.x + offset

        let index = (origin / pageWidth).rounded(.toNearestOrAwayFromZero)
        target.x = (index * pageWidth)

        return target
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}


