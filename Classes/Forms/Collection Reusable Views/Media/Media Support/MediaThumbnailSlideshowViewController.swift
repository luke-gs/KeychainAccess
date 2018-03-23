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

    #if DEBUG
    private let isDebugModeEnabled: Bool = false
    private let box = UIView()
    #endif

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = collectionView.frame.height
        let inset = (collectionView.frame.width - MediaThumbnailSlideshowViewController.focusedItemWidth) * 0.5

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)

        #if DEBUG
        if isDebugModeEnabled {
            box.frame = CGRect(x: inset, y: collectionView.frame.minY, width: MediaThumbnailSlideshowViewController.focusedItemWidth, height: collectionView.bounds.height)
            box.layer.borderColor = UIColor.red.cgColor
            box.layer.borderWidth = 1.0
            box.backgroundColor = .clear
            box.isUserInteractionEnabled = false
            view.addSubview(box)
        }
        #endif
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

        guard isViewLoaded else { return }

        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
            collectionView.scrollRectToVisible(cell.frame, animated: animated)
        } else {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()

            if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) {
                collectionView.scrollRectToVisible(attributes.frame, animated: animated)
            }
        }
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
        if let cell = collectionView.cellForItem(at: indexPath) {
            collectionView.scrollRectToVisible(cell.frame, animated: true)
        }

        focusedIndex = indexPath.item
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
            guard oldValue != itemWidth else { return }
            invalidateLayout()
        }
    }

    public var focusedItemIndex: Int {
        var target = collectionView!.contentOffset
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        var index = Int((origin / pageWidth).rounded(.toNearestOrAwayFromZero))
        return max(min(index, numberOfItems - 1), 0)
    }

    private var cache = [UICollectionViewLayoutAttributes]()

    private var pageIndex: Int {
        var target = collectionView!.contentOffset
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        var index = Int((origin / pageWidth).rounded(.down))
        return max(min(index, numberOfItems - 1), 0)
    }

    private var nextPagePercentage: CGFloat {
        var target = collectionView!.contentOffset
        var offset = collectionView!.contentInset.left
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
        return CGSize(width: (CGFloat(numberOfItems) - 1.0) * pageWidth + focusedItemWidth, height: collectionView!.bounds.height)
    }

    private var lastPageIndex: Int = 0

    public override func prepare() {
        let height = collectionView!.bounds.height
        let numberOfItems = self.numberOfItems
        let pageIndex = self.pageIndex
        let nextPageIndex = pageIndex + 1
        let nextPagePercentage = self.nextPagePercentage
        let currentPagePercentage = 1.0 - nextPagePercentage
        let additionalWidth = focusedItemWidth - itemWidth

        // Optimisation - Modify the two layout attributes that are changing and leave the rest the same.
        // If there are any issues with the layout, try removing this block of code first. But there shouldn't be any.
        if lastPageIndex == pageIndex && numberOfItems == cache.count {
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

        var x: CGFloat = 0
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

        lastPageIndex = pageIndex
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
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        var index = (origin / pageWidth).rounded(.toNearestOrAwayFromZero)
        target.x = (index * pageWidth) - offset

        return target
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}


