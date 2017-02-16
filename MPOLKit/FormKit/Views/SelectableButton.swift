//
//  SelectableButton.swift
//  FormKit
//
//  Created by Rod Brown on 12/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit


open class SelectableButton: UIButton {

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
    
    open var shouldAnimateStateTransition: Bool = false
    
    
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
        
        addTarget(self, action: #selector(_touchUpInside), for: .primaryActionTriggered)
        
        updateAppearance()
    }
    
    
    // MARK: - Event handling
    
    dynamic fileprivate func _touchUpInside() {
        isSelected = self.isSelected == false
        sendActions(for: .valueChanged)
    }
    
    
    // MARK: - Appearance
    
    dynamic open func setTintColor(_ color: UIColor?, forState state: UIControlState) {
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

}
