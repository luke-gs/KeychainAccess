//
//  Optional+Extension.swift
//  MPOLKit
//
//  Created by Kyle May on 26/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension Optional where Wrapped == Bool {
    
    /// Checks that the bool is both true and not nil
    var isTrue: Bool {
        return self ?? false
    }
}
