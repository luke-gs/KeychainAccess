//
//  CheckBox.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

open class CheckBox: SelectableButton {
    
    open class func minimumSize(withTitle title: String) -> CGSize {
        var size = (title as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        size.height = max(size.height, 20.0) + 14.0
        size.width += 30.0
        return size
    }
    
    
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
        shouldAnimateStateTransition = true
        
        let lightGrayColor = UIColor.lightGray
        let disabledColor = lightGrayColor.withAlphaComponent(0.5)
        
        contentEdgeInsets = UIEdgeInsets(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0)
        contentHorizontalAlignment = .left
        
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        titleLabel?.font = .systemFont(ofSize: 14.0)
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitleColor(.darkText, for: .normal)
        setTitleColor(disabledColor, for: .disabled)
        setTitleColor(disabledColor, for: [.selected, .disabled])
        
        setImage(.checkbox, for: .normal)
        
        let selectedImage = UIImage.checkboxSelected
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.selected, .disabled])
        
        setTintColor(lightGrayColor, forState: .normal)
        setTintColor(disabledColor, forState: .disabled)
        setTintColor(disabledColor, forState: [.disabled, .selected])
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
