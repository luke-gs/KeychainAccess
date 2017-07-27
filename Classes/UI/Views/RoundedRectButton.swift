//
//  RoundedRectButton.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit



/// A standard MPOL Rounded Rect button that uses its tint color
/// as the background color.
open class RoundedRectButton: UIButton {

    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel?.font = .systemFont(ofSize: 13.0, weight: UIFontWeightBold)
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .disabled)
        backgroundColor = tintColor
        layer.cornerRadius = 6.0
        layer.shouldRasterize = true
        layer.rasterizationScale = traitCollection.currentDisplayScale
        tintAdjustmentMode = .normal
        
        contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 8.0, right: 20.0)
    }
    
    
    // MARK: - Overrides
    
    open override var isSelected: Bool {
        didSet {
            if isSelected != oldValue { updateBackgroundColor() }
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted != oldValue { updateBackgroundColor() }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.rasterizationScale = traitCollection.currentDisplayScale
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateBackgroundColor()
    }
    
    
    // MARK: - Private methods
    
    private func updateBackgroundColor() {
        backgroundColor = isSelected || isHighlighted ? tintColor.adjustingBrightness(byFactor: 0.75) : tintColor
    }
    
}
