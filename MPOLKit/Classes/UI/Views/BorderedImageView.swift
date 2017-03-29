//
//  BorderedImageView.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// `BorderedImageView` is a wrapper class for a `UIImageView`, with an optional border,
/// and an MPOL style corner radius.
///
/// By setting a border color and width, the image view is inset with a surrounding border.
/// When no border width or color is set, the image view reverts to full size.
public class BorderedImageView: UIView {
    
    /// The internal image view.
    ///
    /// By default, the image view's content mode is set to
    /// `UIViewContentMode.scaleAspectFill`. This ensures that the image
    /// fills the entire border.
    public let imageView = UIImageView(frame: .zero)
    
    
    /// The border color.
    ///
    /// When this value is `nil`, the border is automatically hidden.
    /// The default is `nil`.
    @NSCopying public var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            layer.borderColor = borderColor?.cgColor
            if borderWidth > 0 {
                updateCornerRadius()
            }
        }
    }
    
    
    /// The border width.
    ///
    /// When this value is zero, the border is autmatically hidden.
    /// The default is 2.0.
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            if borderWidth != oldValue && borderColor != nil {
                updateCornerRadius()
            }
        }
    }
    
    public var wantsRoundedCorners: Bool = true {
        didSet {
            if wantsRoundedCorners == oldValue { return }
            
            updateCornerRadius()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        
        updateCornerRadius()
    }
    
    
    // MARK: - Overrides
    
    public override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size && wantsRoundedCorners {
                updateCornerRadius()
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if bounds.size != oldValue.size && wantsRoundedCorners {
                updateCornerRadius()
            }
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateCornerRadius() {
        let bounds = self.bounds
        let cornerRadius = wantsRoundedCorners ? ((min(bounds.width, bounds.height) + 300.0) / 80.0).rounded(toScale: (window?.screen ?? .main).scale) : 0.0
        
        layer.cornerRadius = cornerRadius
        
        if borderColor == nil || borderWidth == 0.0 {
            imageView.layer.cornerRadius = cornerRadius
            imageView.frame = bounds
            layer.borderWidth = 0.0
        } else {
            imageView.layer.cornerRadius = max(cornerRadius - 3.0, 0.0)
            imageView.frame = wantsRoundedCorners ? bounds.insetBy(dx: 4.0, dy: 4.0) : bounds
            layer.borderWidth = borderWidth
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
        
        
    }
    
}
