//
//  CheckBox.swift
//  FormKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

open class CheckBox: SelectableButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setImage(.checkbox, for: .normal)
        
        let selectedImage = UIImage.checkboxSelected
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.selected, .disabled])
    }
    
}
