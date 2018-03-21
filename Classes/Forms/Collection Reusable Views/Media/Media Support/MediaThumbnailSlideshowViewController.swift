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

    public let viewModel: MediaGalleryViewModelable
    public weak var delegate: MediaThumbnailSlideshowViewControllerDelegate?

    private var layout: UICollectionViewFlowLayout!
    private var collectionView: UICollectionView!

    private let focusedItemSize = CGSize(width: 44.0, height: 44.0)
    private let itemSize = CGSize(width: 30.0, height: 44.0)

    private var focusedIndex: Int = 0

    public init(viewModel: MediaGalleryViewModelable) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let toolbar = UIToolbar(frame: view.bounds)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.frame = view.bounds
        view.addSubview(toolbar)

        layout = UICollectionViewFlowLayout()
//        layout.itemSize = itemSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 1.0


        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: ThumbnailLayout())
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubview(collectionView)
    }

    private let box = UIView()

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = collectionView.frame.height
        let inset = (collectionView.frame.width - focusedItemSize.width) * 0.5

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        collectionView.contentOffset = contentOffsetForPageIndex(focusedIndex)

        box.frame = CGRect(x: inset, y: collectionView.frame.minY, width: focusedItemSize.width, height: focusedItemSize.height)
        box.layer.borderColor = UIColor.red.cgColor
        box.layer.borderWidth = 1.0
        box.backgroundColor = .clear
        box.isUserInteractionEnabled = false
        view.addSubview(box)
    }

    // MARK: - Operations

    public func setFocusedIndex(_ index: Int, animated: Bool) {
        guard focusedIndex != index else { return }

        focusedIndex = index

        guard isViewLoaded else { return }

//        collectionView.performBatchUpdates({
//            self.layout.invalidateLayout()
//
//            let focusedRect = contentRectForPageIndex(focusedIndex)
//            self.collectionView.scrollRectToVisible(focusedRect, animated: animated)
//        }, completion: nil)
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.previews.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let preview = viewModel.previews[indexPath.item]

        preview.thumbnailImage?.loadImage(completion: { (image) in
            let imageView = UIImageView(image: image.sizing().image)
            imageView.contentMode = .scaleAspectFill
            cell.backgroundView = imageView
            cell.clipsToBounds = true
        })

        return cell
    }
/*
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setFocusedIndex(indexPath.item, animated: true)
        notifySelectionOfFocusedIndex()
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.isDragging {
            return itemSize
        } else {
            return indexPath.item == focusedIndex ? focusedItemSize : itemSize
        }
    }


    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2) {
            self.collectionView.performBatchUpdates({
                self.layout.invalidateLayout()
            }, completion: nil)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        UIView.animate(withDuration: 0.2) {
            self.collectionView.performBatchUpdates({
                self.layout.invalidateLayout()
                let focusedRect = self.contentRectForPageIndex(self.focusedIndex)
                self.collectionView.scrollRectToVisible(focusedRect, animated: true)
            }, completion: nil)
//        }
//        notifySelectionOfFocusedIndex()
    }
//
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
//            UIView.animate(withDuration: 0.2) {
                self.collectionView.performBatchUpdates({
                    self.layout.invalidateLayout()
                    let focusedRect = self.contentRectForPageIndex(self.focusedIndex)
                    self.collectionView.scrollRectToVisible(focusedRect, animated: true)
                }, completion: nil)
            }
//            notifySelectionOfFocusedIndex()
//        }
    }

    // MARK: - Paging Support

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }

        var target = scrollView.contentOffset

        // Normalise the target for easy calculation
        var offset = scrollView.contentInset.left
        var origin = target.x + offset

        // Find the nearest page number for the content offset
        var pageNumber = Int((origin / pageSize).rounded(.toNearestOrAwayFromZero))

        // Clamps the page numberClamps
        pageNumber = max(min(pageNumber, viewModel.previews.count - 1), 0)

        target.x = (CGFloat(pageNumber) * pageSize) - offset

        // Retain the page index
        focusedIndex = Int(pageNumber)

        notifySelectionOfFocusedIndex()
    }
*/
//    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        var target = targetContentOffset.pointee
//
//        // Normalise the target for easy calculation
//        var offset = scrollView.contentInset.left
//        var origin = target.x + offset
//
//        // Find the nearest page number for the content offset
//        var pageNumber = (origin / pageSize).rounded(.toNearestOrAwayFromZero)
//
//        target.x = (pageNumber * pageSize) - offset
//        targetContentOffset.pointee = target
//
//        // Retain the page index
//        focusedIndex = Int(pageNumber)
//        print("\(scrollView.isDragging)")
//        notifySelectionOfFocusedIndex()
//    }

    private var pageSize: CGFloat {
        return itemSize.width + layout.minimumInteritemSpacing
    }

    private func contentOffsetForPageIndex(_ index: Int) -> CGPoint {
        let offset = collectionView.contentInset.left

        return CGPoint(x: (CGFloat(index) * pageSize) - offset, y: collectionView.contentOffset.y)
    }

    private func contentRectForPageIndex(_ index: Int) -> CGRect {
        let origin = CGPoint(x: pageSize * CGFloat(index), y: 0)

        return CGRect(origin: origin, size: focusedItemSize)
    }

    private func notifySelectionOfFocusedIndex() {
        let preview = viewModel.previews[focusedIndex]
        delegate?.mediaThumbnailSlideshowViewController(self, didSelectPreview: preview)
    }

}


public class ThumbnailLayout: UICollectionViewLayout {

    private var focusedItemWidth: CGFloat = 44.0

    private var itemWidth: CGFloat = 30.0

    private var cache = [UICollectionViewLayoutAttributes]()

    private var focusedItemIndex: Int {
        var target = collectionView!.contentOffset
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        var index = Int((origin / itemWidth).rounded(.down))
        return max(min(index, numberOfItems - 1), 0)
    }

    private var previousItemOffsetX: CGFloat = 0

    private var nextFocusedItemPercentage: CGFloat {
        var target = collectionView!.contentOffset
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        origin = max(min(origin, (CGFloat(numberOfItems) - 1.0) * itemWidth), 0)

        return (origin / itemWidth) - (origin / itemWidth).rounded(.down)
    }

    private var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }

    public override var collectionViewContentSize: CGSize {
        return CGSize(width: (CGFloat(numberOfItems) - 1.0) * itemWidth + focusedItemWidth, height: collectionView!.bounds.height)
    }

    public override func prepare() {
        cache.removeAll()

        let height = collectionView!.bounds.height

        let focusedItemIndex = self.focusedItemIndex
        let nextFocusedItemPercentage = self.nextFocusedItemPercentage

        let isNext = collectionView!.contentOffset.x > previousItemOffsetX

        if isNext {
            var x: CGFloat = 0
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                var width = itemWidth

                if indexPath.item == focusedItemIndex {
                    width = (focusedItemWidth - itemWidth) * (1 - nextFocusedItemPercentage) + itemWidth
                } else if indexPath.item == (focusedItemIndex + 1) {
                    width = (focusedItemWidth - itemWidth) * nextFocusedItemPercentage + itemWidth
                }

                let frame = CGRect(x: x, y: 0, width: width, height: height)

                attributes.frame = frame
                cache.append(attributes)

                x = frame.maxX
            }
        } else {
            var x: CGFloat = collectionViewContentSize.width

            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: (numberOfItems - 1) - item, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                var width = itemWidth

                if indexPath.item == focusedItemIndex {
                    width = (focusedItemWidth - itemWidth) * (1 - nextFocusedItemPercentage) + itemWidth
                } else if indexPath.item == (focusedItemIndex + 1) {
                    width = (focusedItemWidth - itemWidth) * nextFocusedItemPercentage + itemWidth
                }

                let frame = CGRect(x: x - width, y: 0, width: width, height: height)

                attributes.frame = frame
                cache.append(attributes)

                x = frame.minX
            }
        }

        previousItemOffsetX = collectionView!.contentOffset.x
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { (attributes) -> Bool in
            attributes.frame.intersects(rect)
        }
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var target = proposedContentOffset
        var offset = collectionView!.contentInset.left
        var origin = target.x + offset

        var index = (origin / itemWidth).rounded(.toNearestOrAwayFromZero)
        target.x = (index * itemWidth) - offset

        return target
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}


