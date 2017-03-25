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
        backgroundColor = UIColor(white: 0.3, alpha: 0.9)
        textAlignment   = .center
        clipsToBounds   = true
        layoutMargins   = UIEdgeInsets(top: 3.0, left: 10.0, bottom: 2.0, right: 10.0)
        
        let layer = self.layer
        layer.cornerRadius = 2.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text?.isEmpty ?? true { return CGRect.zero }
        
        var rect = bounds.insetBy(layoutMargins)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return rect.insetBy(layoutMargins.inverted())
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(layoutMargins))
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var displayScale = traitCollection.displayScale
        if displayScale ==~ 0 {
            displayScale = UIScreen.main.scale
        }
        
        layer.rasterizationScale = displayScale
    }
    
}
