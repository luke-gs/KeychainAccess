//
//  CollectionViewFormLayoutStyle.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CollectionViewFormLayoutStyle {
    
    public internal(set) weak var formLayout: CollectionViewFormLayout?
    public internal(set) weak var collectionView: UICollectionView?
    
    public var contentSize: CGSize = .zero
    public var sectionRects: [CGRect] = []
    
    public var globalHeaderAttribute: UICollectionViewLayoutAttributes?
    public var globalFooterAttribute: UICollectionViewLayoutAttributes?
    
    public var sectionHeaderAttributes:     [UICollectionViewLayoutAttributes?]  = []
    public var sectionFooterAttributes:     [UICollectionViewLayoutAttributes?]  = []
    public var sectionBackgroundAttributes: [CollectionViewFormDecorationAttributes] = []
    
    public var itemAttributes: [[CollectionViewFormItemAttributes]] = []
    
    public var sectionSeparatorAttributes:  [[CollectionViewFormDecorationAttributes]] = []
    public var rowSeparatorAttributes:      [[CollectionViewFormDecorationAttributes]] = []
    public var itemSeparatorAttributes:     [[CollectionViewFormDecorationAttributes]] = []
    
    fileprivate var _lastLaidOutWidth: CGFloat = 0.0
    
    open func prepare() {
        _lastLaidOutWidth = collectionView?.bounds.width ?? 0.0
    }
    
    open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return _lastLaidOutWidth != newBounds.width
    }
    
}
