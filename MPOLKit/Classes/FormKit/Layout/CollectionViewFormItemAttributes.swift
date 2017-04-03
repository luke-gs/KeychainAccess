//
//  CollectionViewFormAttributes.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 9/05/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A `CollectionViewFormItemAttributes` object extends `UICollectionViewLayoutAttributes`
/// to support applying layout margins to collection view cells.
///
/// Subclasses of `UICollectionViewCell` that want to implement the layout margin recommendations
/// should override `apply(_:)` to set their content view's layout margins.
open class CollectionViewFormItemAttributes: UICollectionViewLayoutAttributes {
    
    /// The preferred layout margins for the item. Cells used within a `CollectionViewFormLayout` should
    /// apply these layout margins to their content.
    open var layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    
    /// The index of the item in the row.
    open var rowIndex: Int = 0
    
    /// The total number of items in the row.
    open var rowItemCount: Int = 1
    
    open var isAtTrailingEdge: Bool = false
    
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormItemAttributes
        copy.layoutMargins    = layoutMargins
        copy.rowIndex         = rowIndex
        copy.rowItemCount     = rowItemCount
        copy.isAtTrailingEdge = isAtTrailingEdge
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormItemAttributes,
              layoutMargins    == comparedAttribute.layoutMargins,
              rowIndex         == comparedAttribute.rowIndex,
              rowItemCount     == comparedAttribute.rowItemCount,
              isAtTrailingEdge == comparedAttribute.isAtTrailingEdge else { return false }
        return super.isEqual(comparedAttribute)
    }
}
