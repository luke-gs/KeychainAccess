//
//  CollectionViewFormDecorationView.swift
//  FormKit
//
//  Created by Rod Brown on 17/12/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

open class CollectionViewFormDecorationView: UICollectionReusableView {
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        backgroundColor = (layoutAttributes as? CollectionViewFormDecorationAttributes)?.backgroundColor
    }
    
}
