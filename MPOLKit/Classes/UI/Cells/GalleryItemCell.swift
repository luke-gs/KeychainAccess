//
//  GalleryItemCell.swift
//  Pods
//
//  Created by Rod Brown on 21/3/17.
//
//

import UIKit

/// A cell for items in `GalleryCollectionViewCell`s.
open class GalleryItemCell: UICollectionViewCell {
    
    internal weak var galleryCell: GalleryCollectionViewCell?
    
}

extension GalleryItemCell: DefaultReusable {
}

extension GalleryItemCell {
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let cell = galleryCell,
            let delegate = cell.delegate,
            let index = cell.galleryCollectionView.indexPath(for: self)?.item {
            return delegate.galleryCell?(cell, canPerformAction: action, forItemAt: index, withSender: sender) ?? false
        } else {
            return false
        }
    }
    
    open override func cut(_ sender: Any?) {
        performAction(#selector(cut(_:)), withSender: sender)
    }
    open override func copy(_ sender: Any?) {
        performAction(#selector(copy(_:)), withSender: sender)
    }
    open override func paste(_ sender: Any?) {
        performAction(#selector(paste(_:)), withSender: sender)
    }
    open override func select(_ sender: Any?){
        performAction(#selector(select(_:)), withSender: sender)
    }
    open override func selectAll(_ sender: Any?){
        performAction(#selector(selectAll(_:)), withSender: sender)
    }
    open override func delete(_ sender: Any?) {
        performAction(#selector(delete(_:)), withSender: sender)
    }
    open override func makeTextWritingDirectionLeftToRight(_ sender: Any?) {
        performAction(#selector(makeTextWritingDirectionLeftToRight(_:)), withSender: sender)
    }
    open override func makeTextWritingDirectionRightToLeft(_ sender: Any?){
        performAction(#selector(makeTextWritingDirectionRightToLeft(_:)), withSender: sender)
    }
    open override func toggleBoldface(_ sender: Any?) {
        performAction(#selector(toggleBoldface(_:)), withSender: sender)
    }
    open override func toggleItalics(_ sender: Any?) {
        performAction(#selector(toggleItalics(_:)), withSender: sender)
    }
    open override func toggleUnderline(_ sender: Any?) {
        performAction(#selector(toggleUnderline(_:)), withSender: sender)
    }
    open override func increaseSize(_ sender: Any?) {
        performAction(#selector(increaseSize(_:)), withSender: sender)
    }
    open override func decreaseSize(_ sender: Any?) {
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
