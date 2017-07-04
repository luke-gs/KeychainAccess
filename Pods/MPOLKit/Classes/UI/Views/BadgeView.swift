//
//  BadgeView.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// `BadgeView` is a `RoundedRectLabel` subclass designed for use as an iOS style count badge.
///
/// `BadgeView` automatically shows and hides depending on whether it has text. To
/// adjust the badge color, update the backgroundColor property.
open class BadgeView: RoundedRectLabel {
    
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
        font = .systemFont(ofSize: 11.0, weight: UIFontWeightSemibold)
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(style: .system)
    }
    
    
    // MARK: - Overrides
    
    open override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    open override var text: String? {
        didSet { isHidden = text?.isEmpty ?? true }
    }
    
    /// Badge view cannot be configured to appear with multiple lines.
    open override var numberOfLines: Int {
        get { return 1 }
        set { }
    }
    
    
    // MARK: - Private methods
    
    private func updateCornerRadius() {
        let bounds = self.bounds
        cornerRadius = (min(bounds.height, bounds.width) * 0.5)
    }
    
}
