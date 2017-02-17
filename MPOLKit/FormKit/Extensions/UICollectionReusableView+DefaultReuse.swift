//
//  UICollectionViewCell+DefaultReuse.swift
//  VCom
//
//  Created by Val on 4/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public extension UICollectionReusableView {
    
    public dynamic class var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
}
