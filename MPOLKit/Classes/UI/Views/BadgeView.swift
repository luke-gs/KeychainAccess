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
    
    public enum Style {
        case system
        case pill
    }
    
    public init(style: Style) {
        super.init(frame: .zero)
        
        switch style {
        case .system:   layoutMargins = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
        case .pill:     layoutMargins = UIEdgeInsets(top: 1.0, left: 8.0, bottom: 1.0, right: 8.0)
        }
        
        textColor = .white
        isHidden = true
        font = .systemFont(ofSize: 11.0, weight: UIFontWeightSemibold)
        
        let layer = self.layer
        layer.masksToBounds   = true
        layer.shouldRasterize = true
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(style: .system)
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
        return rect.insetBy(layoutMargins.inverted()).integral
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
