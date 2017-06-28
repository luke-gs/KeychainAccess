//
//  CollectionViewFormLayoutAttributes.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A `CollectionViewFormLayoutAttributes` object extends `UICollectionViewLayoutAttributes`
/// to support applying layout margins to collection reusable views
///
/// Subclasses of `UICollectionReusableView` that want to implement the layout margin recommendations
/// should override `apply(_:)` to set their layout margins.
open class CollectionViewFormLayoutAttributes: UICollectionViewLayoutAttributes {
    
    open var layoutMargins: UIEdgeInsets = .zero
    
    /// The index of the item in the row.
    open var rowIndex: Int = 0
    
    /// The total number of items in the row.
    open var rowItemCount: Int = 1
    
    open var isAtTrailingEdge: Bool = false
    
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormLayoutAttributes
        copy.layoutMargins    = layoutMargins
        copy.rowIndex         = rowIndex
        copy.rowItemCount     = rowItemCount
        copy.isAtTrailingEdge = isAtTrailingEdge
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormLayoutAttributes,
            layoutMargins    == comparedAttribute.layoutMargins,
            rowIndex         == comparedAttribute.rowIndex,
            rowItemCount     == comparedAttribute.rowItemCount,
            isAtTrailingEdge == comparedAttribute.isAtTrailingEdge else { return false }
        return super.isEqual(comparedAttribute)
    }
    
}
