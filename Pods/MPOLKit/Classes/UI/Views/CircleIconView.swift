//
//  CircleIconView.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/3/17.
//
//

import UIKit

open class CircleIconView: UIView {
    
    /// The icon view for the cell. The default is nil
    public var iconView: UIView? {
        didSet {
            if oldValue == iconView { return }
            
            if oldValue?.superview == self {
                oldValue?.removeFromSuperview()
            }
            
            if let newValue = iconView {
                newValue.translatesAutoresizingMaskIntoConstraints = false
                addSubview(newValue)
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: newValue, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
                    NSLayoutConstraint(item: newValue, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY),
                    NSLayoutConstraint(item: newValue, attribute: .width,  relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 2.0 / 3.0),
                    NSLayoutConstraint(item: newValue, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 2.0 / 3.0)
                ])
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public var color: UIColor? {
        didSet {
            if color == oldValue { return }
            
            setNeedsDisplay()
        }
    }
    
    
    // MARK: = Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        isOpaque    = false
        
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - Overrides
    
    open override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var size = newValue.size
            if size.width !=~ size.height {
                let maxDimension = max(size.width, size.height)
                size.width  = maxDimension
                size.height = maxDimension
            }
            super.frame = CGRect(origin: newValue.origin, size: size)
        }
    }
    
    open override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            var size = newValue.size
            if size.width !=~ size.height {
                let maxDimension = max(size.width, size.height)
                size.width  = maxDimension
                size.height = maxDimension
            }
            super.bounds = CGRect(origin: newValue.origin, size: size)
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        var iconViewIntrinsicSize = iconView?.intrinsicContentSize ?? CGSize(width: 16.0, height: 16.0)
        if iconViewIntrinsicSize.width  ==~ UIViewNoIntrinsicMetric { iconViewIntrinsicSize.width  = 16.0 }
        if iconViewIntrinsicSize.height ==~ UIViewNoIntrinsicMetric { iconViewIntrinsicSize.height = 16.0 }
        
        let maxIconDimension = max(iconViewIntrinsicSize.width, iconViewIntrinsicSize.height)
        let requiredRadius = ceil(maxIconDimension / 2.0 * 3.0)
        return CGSize(width: requiredRadius, height: requiredRadius)
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(color?.cgColor ?? UIColor.gray.cgColor)
        context.fillEllipse(in: bounds)
    }
    
}
