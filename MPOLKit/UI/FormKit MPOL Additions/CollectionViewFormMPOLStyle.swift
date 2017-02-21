//
//  CollectionViewFormMPOLStyle.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


@objc public protocol CollectionViewDelegateMPOLLayout: CollectionViewDelegateFormLayout {
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, separatorStyleForItemAt indexPath: IndexPath) -> CollectionViewFormMPOLStyle.SeparatorStyle
    
}

public class CollectionViewFormMPOLStyle: CollectionViewFormStyle {
    
    @objc(CollectionViewFormMPOLSeparatorStyle) public enum SeparatorStyle: Int {
        case automatic
        
        case indented
        
        case fullWidth
        
        case hidden
    }
    
    public var separatorStyle: SeparatorStyle = .indented {
        didSet {
            if separatorStyle == .automatic {
                separatorStyle = .indented
            }
            
            if separatorStyle != oldValue {
                formLayout?.invalidateLayout()
            }
        }
    }
    
}


extension CollectionViewFormMPOLStyle {
    
    public override func prepare() {
        
        guard let collectionView = self.collectionView,
            let layout = self.formLayout,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else { return }
        
        let delegateIsMPOLDelegate = delegate is CollectionViewDelegateMPOLLayout
        
        let collectionViewWidth = collectionView.bounds.width
        
        let screenScale = (collectionView.window?.screen ?? .main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        let separatorWidth = layout.separatorWidth
        let separatorVerticalSpacing = separatorWidth.ceiled(toScale: screenScale) // This value represents a pixel-aligned adjustment to ensure we don't get blurry cells.
        
        var reusableSectionHeaderAttributes: [CollectionViewFormMPOLHeaderAttributes] = sectionHeaderAttributes.flatMap{$0 as? CollectionViewFormMPOLHeaderAttributes}
        var reusableSectionFooterAttributes: [UICollectionViewLayoutAttributes] = sectionFooterAttributes.flatMap{$0}
        
        var reusableSectionBackgroundAttributes = sectionBackgroundAttributes
        var reusableItemAttributes: [CollectionViewFormItemAttributes]       = itemAttributes.flatMap { $0 }
        var reusableItemSeparators: [CollectionViewFormDecorationAttributes] = itemSeparatorAttributes.flatMap { $0 }
        
    }
    
}



