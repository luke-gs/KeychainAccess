//
//  CollectionViewFormMPOLHeaderAttributes.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A `CollectionViewFormMPOLHeaderAttributes` object extends `UICollectionViewLayoutAttributes`
/// to support indicating the location of a cell item below an MPOL header.
///
/// Subclasses of `UICollectionReusableView` that want to implement the layout margin recommendations
/// should override `apply(_:)` to set their content view's layout margins.
public class CollectionViewFormMPOLHeaderAttributes: UICollectionViewLayoutAttributes {
    
    public var itemPosition: CGFloat = 0.0
    
    public var separatorWidth: CGFloat = 0.0
    
    public var leadingMargin: CGFloat  = 0.0
    
    
    public override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormMPOLHeaderAttributes
        copy.itemPosition = itemPosition
        copy.separatorWidth = separatorWidth
        copy.leadingMargin  = leadingMargin
        return copy
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormMPOLHeaderAttributes,
              itemPosition   ==~ comparedAttribute.itemPosition,
              separatorWidth ==~ comparedAttribute.separatorWidth,
              leadingMargin  ==~ comparedAttribute.leadingMargin else { return false }
        return super.isEqual(comparedAttribute)
    }
    
}
