//
//  SelectableButton.swift
//  FormKit
//
//  Created by Rod Brown on 12/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


open class SelectableButton: UIButton {
    
    internal class func font(compatibleWith traitCollection: UITraitCollection) -> UIFont {
        return .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
    }
    
    // MARK: - Properties
    
    open override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    open override var isHighlighted: Bool {
        didSet { updateAppearance() }
    }
    
    open override var isEnabled: Bool {
        didSet { updateAppearance() }
    }
    
    open var shouldAnimateStateTransition: Bool = true
    
    
    // MARK: - Private properties
    
    fileprivate var tintMap: [UInt: UIColor] = [:]
    
    
    // MARK: - Initialize
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled    = false
        
        if let titleLabel = self.titleLabel {
            titleLabel.font = SelectableButton.font(compatibleWith: traitCollection)
            titleLabel.adjustsFontForContentSizeCategory = true
        }
        
        let lightGrayColor = UIColor.lightGray
        let disabledColor = lightGrayColor.withAlphaComponent(0.5)
        
        contentEdgeInsets = UIEdgeInsets(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0)
        contentHorizontalAlignment = .left
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        
        setTitleColor(.darkText, for: .normal)
        setTitleColor(disabledColor, for: .disabled)
        setTitleColor(disabledColor, for: [.selected, .disabled])
        
        setTintColor(lightGrayColor, forState: .normal)
        setTintColor(disabledColor, forState: .disabled)
        setTintColor(disabledColor, forState: [.disabled, .selected])
        
        addTarget(self, action: #selector(_touchUpInside), for: .primaryActionTriggered)
        
        updateAppearance()
    }
    
    
    // MARK: - Event handling
    
    @objc fileprivate func _touchUpInside() {
        isSelected = self.isSelected == false
        sendActions(for: .valueChanged)
    }
    
    
    // MARK: - Appearance
    
    @objc dynamic open func setTintColor(_ color: UIColor?, forState state: UIControlState) {
        if let color = color {
            tintMap[state.rawValue] = color
        } else {
            tintMap.removeValue(forKey: state.rawValue)
        }
        updateAppearance()
    }
    
    open func tintColorForState(_ state: UIControlState) -> UIColor? {
        return tintMap[state.rawValue]
    }
    
    fileprivate func updateAppearance() {
        tintColor = tintColorForState(self.state)
        
        if shouldAnimateStateTransition {
            let animation = CATransition()
            animation.type = kCATransitionFade
            animation.duration = 0.1
            layer.add(animation, forKey: "stateTransition")
        }
    }
    
    // MARK: - Intrinsic content size
    
    open override var intrinsicContentSize : CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        
        if (title(for: state)?.isEmpty ?? true) == false {
            intrinsicContentSize.width += 12.0
        }
        
        return intrinsicContentSize
    }

}
