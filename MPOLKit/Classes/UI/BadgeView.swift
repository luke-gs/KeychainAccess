//
//  BadgeView.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// `BadgeView` is a `UILabel` subclass designed for use as an iOS style count badge.
///
/// `BadgeView` automatically shows and hides depending on whether it has text. To
/// adjust the badge color, update the backgroundColor property.
public class BadgeView: UILabel {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layoutMargins = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
        layer.masksToBounds = true
        textColor = .white
        isHidden = true
        font = .systemFont(ofSize: 11.0, weight: UIFontWeightSemibold)
    }
    
}


// MARK: - Overrides
/// Overrides
extension BadgeView {
    
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
    
    public override var text: String? {
        didSet { isHidden = text?.isEmpty ?? true }
    }
    
    /// Badge view cannot be configured to appear with multiple lines.
    public override var numberOfLines: Int {
        get { return 1 }
        set { }
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = bounds.insetBy(layoutMargins)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return rect.insetBy(layoutMargins.inverse).integral
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(layoutMargins))
    }
    
}

// MARK: - Private methods
/// Private methods
fileprivate extension BadgeView {
    
    fileprivate func updateCornerRadius() {
        let bounds = self.bounds
        let radius = (min(bounds.height, bounds.width) * 0.5)
        
        layer.cornerRadius = radius
    }
    
}
