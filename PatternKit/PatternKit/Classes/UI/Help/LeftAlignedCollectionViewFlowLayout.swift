//
//  LeftAlignedCollectionViewFlowLayout.swift
//  MPOLKit
//
//  Created by Megan Efron on 11/9/17.
//
//

import UIKit


/// Aligns cells to the left with `minimumInterimSpacing` (the default behaviour of flow layout
/// spaces cells in row with even spacing in order to fill rows full width).
///
/// https://stackoverflow.com/questions/22539979/left-align-cells-in-uicollectionview
///
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}
