//
//  GalleryCollectionViewCell.swift
//  MPOL-UI
//
//  Created by Rod Brown on 28/06/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

/// A cell to present a horizontally scrolling gallery of items.
open class GalleryCollectionViewCell: CollectionViewFormCell {
    
    /// The delegate for the gallery. Setting this will automatically cause a reload.
    open weak var delegate: GalleryCollectionViewCellDelegate? {
        didSet { galleryCollectionView.reloadData() }
    }
    
    /// The size for items in the gallery. The default is 100.0 x 100.0.
    open var itemSize: CGSize {
        get { return flowLayout.itemSize }
        set { flowLayout.itemSize = newValue }
    }
    
    /// The horizontal space between items. The default is 10.0
    open var interitemSpace: CGFloat {
        get { return flowLayout.minimumInteritemSpacing }
        set { flowLayout.minimumInteritemSpacing = newValue }
    }
    
    /// The indicator style for the gallery scroll view. The default is UIScrollViewIndicatorStyle.Default.
    open var scrollIndicatorStyle: UIScrollViewIndicatorStyle {
        get { return galleryCollectionView.indicatorStyle }
        set { galleryCollectionView.indicatorStyle = newValue }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            if layoutMargins == oldValue { return }
            flowLayout.sectionInset = layoutMargins
            invalidateIntrinsicContentSize()
        }
    }
    
    public var contentWidth: CGFloat {
        return galleryCollectionView.contentSize.width
    }
    
    public var contentOffset: CGFloat {
        get { return galleryCollectionView.contentOffset.x }
        set { setContentOffset(newValue, animated: true) }
    }
    
    public var numberOfItems: Int {
        return galleryCollectionView.numberOfItems(inSection: 0)
    }
    
    public func setContentOffset(_ offset: CGFloat, animated: Bool) {
        galleryCollectionView.setContentOffset(CGPoint(x: offset, y: 0.0), animated: animated)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil // Set the delegate back to nil (ensuring a reload to zero, and preparation for any further reuse)
    }
    
    fileprivate let flowLayout:     UICollectionViewFlowLayout
    fileprivate let galleryCollectionView: UICollectionView
    
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
    
    open override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: ceil(itemSize.height + layoutMargins.top + layoutMargins.bottom))
    }
    
    open func reloadData() {
        galleryCollectionView.reloadData()
    }
    
    open func rectForItem(at index: Int) -> CGRect {
        guard let attributes = galleryCollectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else {
            return .zero
        }
        
        return convert(attributes.frame, from: galleryCollectionView)
    }
}


/// The delegate protocol for a GalleryCollectionViewCell.
/// The delegate is responsible for entering content in the cell.
@objc public protocol GalleryCollectionViewCellDelegate: NSObjectProtocol {
    
    /// Returns the number of items in the gallery.
    func numberOfItems(in cell: GalleryCollectionViewCell) -> Int
    
    /// Returns a preview image for the items in the gallery.
    func galleryCell(_ cell: GalleryCollectionViewCell, previewForItemAt index: Int) -> UIImage?
    
    /// Returns an accessory icon to display over the image
    func galleryCell(_ cell: GalleryCollectionViewCell, accessoryIconAt index: Int) -> UIImage?
    
    /// Notifies the delegate that the user selected an item in the gallery.
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, didSelectItemAt index: Int)
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, shouldShowMenuForItemAt index: Int) -> Bool
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, canPerformAction action: Selector, forItemAt index: Int, withSender sender: Any?) -> Bool
    
    @objc optional func galleryCell(_ cell: GalleryCollectionViewCell, performAction action: Selector, forItemAt index: Int, withSender sender: Any?)
    @objc optional func galleryCellDidScroll(_ cell: GalleryCollectionViewCell)
}

extension GalleryCollectionViewCell {
    
    func insertItem(at index: Int) {
        galleryCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func deleteItem(at index: Int) {
        galleryCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}


extension GalleryCollectionViewCell: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: GalleryItemCell.self, for: indexPath)
        
        cell.galleryCell = self
        cell.imageView.image = delegate?.galleryCell(self, previewForItemAt: indexPath.item)
        cell.tagsIndicatorView.image = delegate?.galleryCell(self, accessoryIconAt: indexPath.item)
        
        return cell
    }
}

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
        }
    }
    
    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {}
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
}


private class GalleryItemCell: UICollectionViewCell, DefaultReusable {
    
    let imageView: UIImageView = UIImageView(frame: .zero)
    let tagsIndicatorView: UIImageView = UIImageView(frame: .zero)
    
    fileprivate weak var galleryCell: GalleryCollectionViewCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        
        contentView.clipsToBounds = true
        addSubview(tagsIndicatorView)
        
        tagsIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tagsIndicatorView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, constant: -8.0),
            NSLayoutConstraint(item: tagsIndicatorView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, constant: -8.0),
            NSLayoutConstraint(item: tagsIndicatorView, attribute: .width, relatedBy: .equal, toConstant: 24.0),
            NSLayoutConstraint(item: tagsIndicatorView, attribute: .height, relatedBy: .equal, toConstant: 22.0)
        ])
        
        backgroundView = imageView
        
        let selectionView = UIView(frame: .zero)
        selectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3991527289)
        selectionView.layer.cornerRadius = 10.0
        selectedBackgroundView = selectionView
    }
}

extension GalleryItemCell {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let cell = galleryCell,
            let delegate = cell.delegate,
            let index = cell.galleryCollectionView.indexPath(for: self)?.item {
            return delegate.galleryCell?(cell, canPerformAction: action, forItemAt: index, withSender: sender) ?? false
        } else {
            return false
        }
    }

    override func cut(_ sender: Any?) {
        performAction(#selector(cut(_:)), withSender: sender)
    }
    override func copy(_ sender: Any?) {
        performAction(#selector(copy(_:)), withSender: sender)
    }
    override func paste(_ sender: Any?) {
        performAction(#selector(paste(_:)), withSender: sender)
    }
    override func select(_ sender: Any?){
        performAction(#selector(select(_:)), withSender: sender)
    }
    override func selectAll(_ sender: Any?){
        performAction(#selector(selectAll(_:)), withSender: sender)
    }
    override func delete(_ sender: Any?) {
        performAction(#selector(delete(_:)), withSender: sender)
    }
    override func makeTextWritingDirectionLeftToRight(_ sender: Any?) {
        performAction(#selector(makeTextWritingDirectionLeftToRight(_:)), withSender: sender)
    }
    override func makeTextWritingDirectionRightToLeft(_ sender: Any?){
        performAction(#selector(makeTextWritingDirectionRightToLeft(_:)), withSender: sender)
    }
    override func toggleBoldface(_ sender: Any?) {
        performAction(#selector(toggleBoldface(_:)), withSender: sender)
    }
    override func toggleItalics(_ sender: Any?) {
        performAction(#selector(toggleItalics(_:)), withSender: sender)
    }
    override func toggleUnderline(_ sender: Any?) {
        performAction(#selector(toggleUnderline(_:)), withSender: sender)
    }
    override func increaseSize(_ sender: Any?) {
        performAction(#selector(increaseSize(_:)), withSender: sender)
    }
    override func decreaseSize(_ sender: Any?) {
        performAction(#selector(decreaseSize(_:)), withSender: sender)
    }
    
    private func performAction(_ action: Selector, withSender sender: Any?) {
        if let galleryCell = self.galleryCell,
            let delegate = galleryCell.delegate,
            let index = galleryCell.galleryCollectionView.indexPath(for: self)?.item {
            delegate.galleryCell?(galleryCell, performAction: action, forItemAt: index, withSender: sender)
        }
    }
}
