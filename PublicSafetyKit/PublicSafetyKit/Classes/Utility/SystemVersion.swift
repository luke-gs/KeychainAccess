//
//  SystemVersion.swift
//  MPOLKit
//
//  Created by Kyle May on 10/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class SystemVersion {
    
    /// Convenience method for checking system version, since `if !#available` isn't a thing.
    public class func isLessThanIOS11() -> Bool {
        // Have to hard-code as variable doesn't work
        if #available(iOS 11, *) {
            return false
        } else {
            return true
        }
    }
    
}
