//
//  UIScreen+SinglePixel.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 20/9/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public var singlePixelSize: CGFloat {
        return 1.0 / scale
    }
    
}
