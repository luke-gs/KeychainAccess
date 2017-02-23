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
    
    /// The position of the item below within the y-axis of the header's frame.
    public var itemPosition: CGFloat = 0.0
    
}

extension CollectionViewFormMPOLHeaderAttributes {
    
    public override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormMPOLHeaderAttributes
        copy.itemPosition = itemPosition
        return copy
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormMPOLHeaderAttributes else { return false }
        if fabs(itemPosition - comparedAttribute.itemPosition) > 1e-15   { return false }
        return super.isEqual(comparedAttribute)
    }
    
}
