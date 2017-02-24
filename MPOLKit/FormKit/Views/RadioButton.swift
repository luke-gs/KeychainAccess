//
//  RadioButton.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

open class RadioButton: SelectableButton {
    
    open class func minimumSize(withTitle title: String) -> CGSize {
        var size = (title as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        size.height = max(size.height, 20.0) + 14.0
        size.width += 40.0
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
        setImage(.radioButton, for: .normal)
        
        let selectedImage = UIImage.radioButtonSelected
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.selected, .disabled])
    }
    
    
}
