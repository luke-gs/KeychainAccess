//
//  RadioButton.swift
//  MPOLKit
//
//  Created by Rod Brown on 6/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

open class RadioButton: SelectableButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let assetManager = AssetManager.shared
        
        setImage(assetManager.image(forKey: .radioButton), for: .normal)
        
        let selectedImage = assetManager.image(forKey: .radioButtonSelected)
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.selected, .disabled])
    }
    
    
}
