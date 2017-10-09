//
//  IntrinsicHeightCollectionView.swift
//  MPOLKit
//
//  Created by Kyle May on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IntrinsicHeightCollectionView: UICollectionView {
    
    open override var intrinsicContentSize: CGSize {
        var size = contentSize
        size.height += contentInset.top + contentInset.bottom
        return size
    }
    
    open override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}
