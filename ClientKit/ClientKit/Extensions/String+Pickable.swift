//
//  String+Pickable.swift
//  ClientKit
//
//  Created by Rod Brown on 10/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import MPOLKit

extension String: Pickable {
    
    public var title: String? {
        return self
    }
    
    public var subtitle: String? {
        return nil
    }
    
}
