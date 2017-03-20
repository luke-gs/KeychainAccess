//
//  GalleryCollectionViewCell.swift
//  Pods
//
//  Created by Rod Brown on 20/3/17.
//
//

import UIKit

/// A cell to present a horizontally scrolling gallery of items.
open class GalleryCollectionViewCell: CollectionViewFormCell {
    
    /// The delegate for the gallery. Setting this will automatically cause a reload.
    public weak var delegate: GalleryCollectionViewCellDelegate? {
        didSet { galleryCollectionView.reloadData() }
    }
    
    /// The layout for the cell. This property is private to the class.
    fileprivate let flowLayout: UICollectionViewFlowLayout
    
    /// The internal collection view.
    internal let galleryCollectionView: UICollectionView
    
    public override init(frame: CGRect) {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100.0, height: 100.0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        
        galleryCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size), collectionViewLayout: flowLayout)
        galleryCollectionView.register(GalleryItemCell.self)
        galleryCollectionView.alwaysBounceHorizontal = true
        galleryCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        galleryCollectionView.backgroundColor  = .clear
        
        super.init(frame: frame)
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate   = self
        
        flowLayout.sectionInset = layoutMargins
        contentView.addSubview(galleryCollectionView)
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: .zero)
    }
    
}

// MARK: - Content
/// Content
extension GalleryCollectionViewCell {
    
    /// The size for items in the gallery. The default is 100.0 x 100.0.
    public var itemSize: CGSize {
        get { return flowLayout.itemSize }
        set { flowLayout.itemSize = newValue }
    }
    
    /// The horizontal space between items. The default is 10.0
    public var interitemSpace: CGFloat {
        get { return flowLayout.minimumInteritemSpacing }
        set { flowLayout.minimumInteritemSpacing = newValue }
    }
    
    /// The indicator style for the gallery scroll view. The default is UIScrollViewIndicatorStyle.Default.
    public var scrollIndicatorStyle: UIScrollViewIndicatorStyle {
        get { return galleryCollectionView.indicatorStyle }
        set { galleryCollectionView.indicatorStyle = newValue }
    }
    
    /// The current content width of the scrolling content.
    public var contentWidth: CGFloat {
        return galleryCollectionView.contentSize.width
    }
    
    /// The content offset for the scrolling content. This is only the x coordinate.
    ///
    /// Setting this updates the content offset without animation.
    public var contentOffset: CGFloat {
        get { return galleryCollectionView.contentOffset.x }
        set { setContentOffset(newValue, animated: false) }
    }
    
    /// Updates the content offset of the scrolling content, with an optional animation.
    ///
    /// - Parameters:
    ///   - offset:   The new offset for the content's x coordinate.
    ///   - animated: A boolean value indicating whether the change should be animated.
    public func setContentOffset(_ offset: CGFloat, animated: Bool) {
        galleryCollectionView.setContentOffset(CGPoint(x: offset, y: 0.0), animated: animated)
    }
    
    /// The number of items currently in the gallery.
    public var numberOfItems: Int {
        return galleryCollectionView.numberOfItems(inSection: 0)
    }
    
    /// The rectangle for the item at in the gallery.
    public func rectForItem(at index: Int) -> CGRect? {
        if let attributes = galleryCollectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) {
            return convert(attributes.frame, from: galleryCollectionView)
        } else {
            return nil
        }
    }
    
    /// Inserts the item into the gallery.
    ///
    /// - Parameter index: The index to insert the item at.
    public func insertItem(at index: Int) {
        galleryCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    /// Deletes the specified item from the gallery.
    ///
    /// - Parameter index: The index to delete the item.
    public func deleteItem(at index: Int) {
        galleryCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    /// Reloads the cell's content.
    public func reloadData() {
        galleryCollectionView.reloadData()
    }
    
}

// MARK: - Collection view data source
/// Collection view data source
extension GalleryCollectionViewCell: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = self.delegate else { fatalError("No delegate specified.") }
        
        let cell = delegate.galleryCell(self, cellForItemAt: indexPath.item)
        cell.galleryCell = self
        return cell
    }
}

// MARK: Collection view delegate
/// Collection view delegate
extension GalleryCollectionViewCell: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.galleryCell?(self, didSelectItemAt: indexPath.item)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return delegate?.galleryCell?(self, shouldShowMenuForItemAt: indexPath.item) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return delegate?.galleryCell?(self, canPerformAction: action, forItemAt: indexPath.item, withSender: sender) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        delegate!.galleryCell!(self, performAction: action, forItemAt: indexPath.item, withSender: sender)
    }
    
    
    // These methods are overriden to block methods available in CollectionViewFormCell. These methods relate to swipe-to-delete.
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == galleryCollectionView {
            delegate?.galleryCellDidScroll?(self)
        } else {
            super.scrollViewDidScroll(scrollView)
        }
    }
    
    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView != galleryCollectionView {
            super.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView != galleryCollectionView {
            super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != galleryCollectionView {
            super.scrollViewWillBeginDragging(scrollView)
        }
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != galleryCollectionView {
            super.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView != galleryCollectionView {
            super.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
}


// MARK: - Overrides
/// Overrides
extension GalleryCollectionViewCell {
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil // Set the delegate back to nil (ensuring a reload to zero), and preparation for any further reuse.
        galleryCollectionView.reloadData()
    }
    
    open override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: ceil(itemSize.height + layoutMargins.top + layoutMargins.bottom))
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            if layoutMargins == oldValue { return }
            flowLayout.sectionInset = layoutMargins
            invalidateIntrinsicContentSize()
        }
    }
    
}


/// The delegate protocol for a GalleryCollectionViewCell.
///
/// The delegate is responsible for entering content in the cell.
@objc public protocol GalleryCollectionViewCellDelegate: NSObjectProtocol {
    
    /// Returns the number of items in the gallery.
    func numberOfItems(in cell: GalleryCollectionViewCell) -> Int
    
    /// Returns the child cell for the item in the gallery.
    func galleryCell(_ cell: GalleryCollectionViewCell, cellForItemAt index: Int) -> GalleryItemCell
    
    /// Notifies the delegate that the user selected an item in the gallery.
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, didSelectItemAt index: Int)
    
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, shouldShowMenuForItemAt index: Int) -> Bool
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, canPerformAction action: Selector, forItemAt index: Int, withSender sender: Any?) -> Bool
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, performAction action: Selector, forItemAt index: Int, withSender sender: Any?)
    
    @objc optional func galleryCellDidScroll(_ cell: GalleryCollectionViewCell)
}

