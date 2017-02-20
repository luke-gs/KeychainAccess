//
//  BorderedImageView.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class BorderedImageView: UIView {
    
    public let imageView = UIImageView(frame: .zero)
    
    public var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            layer.borderColor = borderColor?.cgColor
            updateCornerRadius()
        }
    }
    
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            if borderWidth != oldValue && borderColor != nil {
                updateCornerRadius()
            }
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
    
}


extension BorderedImageView {
    
    public override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    fileprivate func updateCornerRadius() {
        let bounds = self.bounds
        let cornerRadius = ((min(bounds.width, bounds.height) + 300.0) / 80.0).rounded(toScale: (window?.screen ?? .main).scale)
        
        layer.cornerRadius = cornerRadius
        
        if borderColor == nil {
            imageView.layer.cornerRadius = 0.0
            imageView.frame = bounds
            layer.borderWidth = 0.0
        } else {
            imageView.layer.cornerRadius = max(cornerRadius - 3.0, 0.0)
            imageView.frame = bounds.insetBy(dx: 4.0, dy: 4.0)
            layer.borderWidth = borderWidth
        }
    }
    
}
