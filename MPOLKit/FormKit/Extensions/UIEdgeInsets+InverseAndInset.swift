//
//  UIEdgeInsets+InverseAndInset.swift
//  VCom
//
//  Created by Rod Brown on 4/06/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    public var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
}

extension CGRect {
    
    public func insetBy(_ edgeInsets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, edgeInsets)
    }
    
}
