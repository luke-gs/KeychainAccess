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
public final class RoundedRectLabel : UILabel {
    
    public var textInsets: UIEdgeInsets = UIEdgeInsets(top: 2.0, left: 10.0, bottom: 2.0, right: 10.0)
    
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
        layer.cornerRadius = 2.0
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text?.isEmpty ?? true { return CGRect.zero }
        
        var rect = bounds.insetBy(textInsets)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return rect.insetBy(textInsets.inverse)
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(textInsets))
    }
    
}
