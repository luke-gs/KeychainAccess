//
//  RoundedRectLabel.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


/// A label subclass for creating a rounded rectangle background border
/// appearance around text. This is generally used to show a source or a
/// priority level.
open class RoundedRectLabel : UILabel {
    
    open var cornerRadius: CGFloat = 2.0 {
        didSet {
            if cornerRadius ==~ oldValue { return }
        }
    }
    
    open override var backgroundColor: UIColor? {
        get { return _backgroundColor }
        set {
            if _backgroundColor == newValue {
                return
            }
            _backgroundColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    private var _backgroundColor: UIColor?
    
    
    
    // MARK: - Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        font            = .systemFont(ofSize: 10.0, weight: UIFontWeightBold)
        textColor       = .white
        textAlignment   = .center
        isOpaque        = false
        backgroundColor =  UIColor(white: 0.3, alpha: 0.9)
        
        // Visually this appears slightly different on devices depending on scale. We vary the numbers depending on the screen scale.
        layoutMargins = UIEdgeInsets(top: 2.0 + (1.0 / UIScreen.main.scale), left: 10.0, bottom: 2.0, right: 10.0)
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text?.isEmpty ?? true { return CGRect.zero }
        
        let rect = super.textRect(forBounds: bounds.insetBy(layoutMargins), limitedToNumberOfLines: numberOfLines)
        return rect.insetBy(layoutMargins.inverted())
    }
    
    open override func draw(_ rect: CGRect) {
        
        if let background = _backgroundColor {
            background.setFill()
            if cornerRadius > 0.0, let context = UIGraphicsGetCurrentContext() {
                context.addPath(CGPath(roundedRect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
                context.fillPath()
            } else {
                UIRectFill(bounds)
            }
        }
        
        super.draw(rect)
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(layoutMargins))
    }
    
}
