//
//  SpacerView.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A spacer view for convenience use within `UIStackView`.
///
/// It is recommended you avoid using this class except where necessary.
/// Generally you can get the same behaviour in all areas with a
/// `UILayoutGuide`, except stack views which require views.
///
/// In iOS 11+, you should use `UIStackView`'s custom separation API
/// and avoid using this API, except where you might need custom compression
/// and hugging priorities.
open class SpacerView: UIView {
    
    /// The preferred size for the view. This is used as the intrinsic
    /// content sie for the view. The default is the size of the view
    /// at initialization.
    open var size: CGSize {
        didSet {
            if size != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    

    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        size = frame.size
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        size = .zero
        super.init(coder: aDecoder)
        size = bounds.size
        isUserInteractionEnabled = false
    }
    
    
    // MARK: - Overrides
    
    open override class var layerClass: AnyClass {
        return CATransformLayer.self
    }
    
    open override var intrinsicContentSize: CGSize {
        return size
    }
    
}
