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
    
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormItemAttributes
        copy.layoutMargins = layoutMargins
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormItemAttributes else { return false }
        if layoutMargins != comparedAttribute.layoutMargins { return false }
        return super.isEqual(comparedAttribute)
    }
}



/// A `CollectionViewFormDecorationAttributes` object extends `UICollectionViewLayoutAttributes`
/// to support applying appearance attributes to decoration views.
///
/// Subclasses of `UICollectionReusableView` that want to implement the visual recommendations
/// should override `apply(_:)` to set their background colors.
open class CollectionViewFormDecorationAttributes: UICollectionViewLayoutAttributes {
    
    /// The requested background color.
    open var backgroundColor: UIColor?
    
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFormDecorationAttributes
        copy.backgroundColor = backgroundColor
        return copy
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let comparedAttribute = object as? CollectionViewFormDecorationAttributes else { return false }
        if backgroundColor != comparedAttribute.backgroundColor { return false }
        return super.isEqual(comparedAttribute)
    }
}
